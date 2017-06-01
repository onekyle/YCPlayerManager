//
//  YCPlayer.m
//  Pods
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayer.h"


@interface _YCPrivatePlayer : AVPlayer
@property (nonatomic, weak) YCPlayer *owner;
@end

@implementation _YCPrivatePlayer

- (void)pause
{
    if (!self.owner.hasCorrectFalg) {
        [super pause];
        self.owner.status = YCPlayerStatusPause;
    }
}

- (void)pauseWithNoChangeStatus
{
    YCPlayer *owner = _owner;
    _owner = nil;
    [self pause];
    _owner = owner;
}

- (void)play
{
    [super play];
    self.owner.status = YCPlayerStatusPlaying;
}


@end

static void *YCPlayerStatusObservationContext = &YCPlayerStatusObservationContext;
static NSArray *_observerKeyPathArray = nil;

struct YCPlayerDelegateFlags {
    unsigned int playPeriodicTimeChanged : 1;
    unsigned int bufferingLoaded : 1;
    unsigned int statusChanged : 1;
};
typedef struct YCPlayerDelegateFlags YCPlayerDelegateFlags;

@interface YCPlayer ()
{
    _YCPrivatePlayer *_metaPlayer;
}

/** 监听播放进度的timer*/
@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic, assign) YCPlayerDelegateFlags delegateFlags;
@end

@implementation YCPlayer
@synthesize metaPlayer = _metaPlayer;

- (instancetype)initWithMediaURLString:(NSString *)mediaURLString
{
    self = [super init];
    if (self) {
        [self startPlayingWithMediaURLString:mediaURLString completionHandler:nil];
    }
    return self;
}

- (void)dealloc
{
    [self reset];
}

- (void)setPlayerDelegate:(id<YCPlayerDelegate>)playerDelegate
{
    _playerDelegate = playerDelegate;
    if ([playerDelegate conformsToProtocol:@protocol(YCPlayerDelegate)]) {
        _delegateFlags.playPeriodicTimeChanged = [playerDelegate respondsToSelector:@selector(player:playPeriodicTimeChangeTo:)];
        _delegateFlags.bufferingLoaded = [playerDelegate respondsToSelector:@selector(player:bufferingWithCurrentLoadedTime:duration:)];
        _delegateFlags.statusChanged = [playerDelegate respondsToSelector:@selector(player:didChangeToStatus:fromStatus:)];
    } else {
        _delegateFlags.playPeriodicTimeChanged = NO;
        _delegateFlags.bufferingLoaded = NO;
        _delegateFlags.statusChanged = NO;
    }
}

- (void)startPlayingWithMediaURLString:(NSString *)mediaURLString completionHandler:(void(^)())completionHandler
{
    _mediaURLString = [mediaURLString copy];
    [_metaPlayer pauseWithNoChangeStatus];
    self.status = YCPlayerStatustransitioning;
    [self.currentItem.asset cancelLoading];
    self.currentItem = nil;
    if (mediaURLString == nil) {
        return;
    }
    
    AVAsset *asset = [self getAssetWithURLString:_mediaURLString];
    __weak typeof(self) weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            AVKeyValueStatus status = [asset statusOfValueForKey:@"duration" error:nil];
            if (status == AVKeyValueStatusLoaded) {
                weakSelf.currentItem = [AVPlayerItem playerItemWithAsset:asset];
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf->_mediaURLString) {
                    weakSelf.status = YCPlayerStatusBuffering;
                }
                if (completionHandler) {
                    completionHandler();
                }
            } else if (status == AVKeyValueStatusFailed) {
                [weakSelf.metaPlayer replaceCurrentItemWithPlayerItem:nil];
                weakSelf.status = YCPlayerStatusFailed;
            } else if (status == AVKeyValueStatusCancelled) {
                [weakSelf.metaPlayer replaceCurrentItemWithPlayerItem:nil];
            }
        });
    }];
    
}

- (void)setCurrentItem:(AVPlayerItem *)currentItem
{
    if (_currentItem == currentItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        @try {
            [_metaPlayer removeTimeObserver:_playbackTimeObserver];
            _playbackTimeObserver = nil;
        } @catch (NSException *exception) {
            NSLog(@"func: %s, exception: %@",__func__,exception);
        }
        
        for (NSString *keyPathStr in [YCPlayer observerKeyPathArray]) {
            [_currentItem removeObserver:self forKeyPath:keyPathStr];
        }
        _currentItem = nil;
    }
    _currentItem = currentItem;
    if (_currentItem) {
        for (NSString *keyPathStr in [YCPlayer observerKeyPathArray]) {
            [_currentItem addObserver:self forKeyPath:keyPathStr options:NSKeyValueObservingOptionNew context:YCPlayerStatusObservationContext];
        }
        if (!_metaPlayer) {
            _metaPlayer = [[_YCPrivatePlayer alloc] initWithPlayerItem:_currentItem];
            _metaPlayer.owner = self;
            _metaPlayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        } else {
            [_metaPlayer replaceCurrentItemWithPlayerItem:_currentItem];
        }
        _currentLayer = [AVPlayerLayer playerLayerWithPlayer:_metaPlayer];
        _currentLayer.backgroundColor = [UIColor blackColor].CGColor;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        
    }
}

- (void)setStatus:(YCPlayerStatus)status
{
    YCPlayerStatus oldStatus = _status;
    _status = status;
    if (_delegateFlags.statusChanged) {
        [_playerDelegate player:self didChangeToStatus:status fromStatus:oldStatus];
    }
}

- (void)handleChangeAboutAVPlayerStatus:(AVPlayerStatus)status
{
    switch (status) {
        case AVPlayerStatusUnknown:
        {
            self.status = YCPlayerStatusBuffering;
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            if (self.status != YCPlayerStatusReadyToPlay) {
                self.status = YCPlayerStatusReadyToPlay;
                [self addplayerPlayProgressTimeObserver];
            }
            /* Once the AVPlayerItem becomes ready to play, i.e.
             [playerItem status] == AVPlayerItemStatusReadyToPlay,
             its duration can be fetched from the item. */
        }
            break;
            
        case AVPlayerStatusFailed:
        {
            self.status = YCPlayerStatusFailed;
        }
            break;
        default:
            break;
    }
}

- (void)reset
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_metaPlayer.currentItem cancelPendingSeeks];
    [_metaPlayer.currentItem.asset cancelLoading];
    [_metaPlayer pause];
    
    [_metaPlayer removeTimeObserver:_playbackTimeObserver];
    //移除观察者
    for (NSString *keyPathStr in [YCPlayer observerKeyPathArray]) {
        [_currentItem removeObserver:self forKeyPath:keyPathStr];
    }
    
    [_metaPlayer replaceCurrentItemWithPlayerItem:nil];
    _metaPlayer = nil;
    _currentItem = nil;
    [_currentLayer removeFromSuperlayer];
    _currentLayer = nil;
}

- (AVAsset *)getAssetWithURLString:(NSString *)url
{
    if (!url.length) {
        return nil;
    }
    if ([url rangeOfString:@"http"].location != NSNotFound) {
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return asset;
    } else {
        AVAsset *asset  = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:url]];
        return asset;
    }
}

- (void)addplayerPlayProgressTimeObserver
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    if (_playbackTimeObserver) {
        @try {
            [_metaPlayer removeTimeObserver:_playbackTimeObserver];
        } @catch (NSException *exception) {
            NSLog(@"func: %s, exception: %@",__func__,exception);
        }
    }
    __weak typeof(self) weakSelf = self;
    _playbackTimeObserver =  [weakSelf.metaPlayer
                                  addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)
                                  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
                                  usingBlock:^(CMTime time){
                                      if (weakSelf.delegateFlags.playPeriodicTimeChanged) {
                                          [weakSelf.playerDelegate player:weakSelf playPeriodicTimeChangeTo:time];
                                      }
                                  }];
}

- (void)moviePlayDidEnd:(NSNotification *)notification
{
//    [self.player removeTimeObserver:self.playbackTimeObserver];
    [self.metaPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
    self.status = YCPlayerStatusFinished;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == YCPlayerStatusObservationContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            [self handleChangeAboutAVPlayerStatus:status];
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval currentLoadedTime = [self availableDuration];
            NSTimeInterval duration = CMTimeGetSeconds(self.currentItem.duration);
            if (_delegateFlags.bufferingLoaded) {
                [_playerDelegate player:self bufferingWithCurrentLoadedTime:currentLoadedTime duration:duration];
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.currentItem.isPlaybackBufferEmpty) {
                self.status = YCPlayerStatusBuffering;
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.currentItem.isPlaybackLikelyToKeepUp && (self.status == YCPlayerStatusBuffering || self.status == YCPlayerStatusFailed)){
                self.status = YCPlayerStatusPlaying;
            }
        }
    }
}

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = _currentItem.loadedTimeRanges;
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (CMTime)playerItemDuration{
    if (_currentItem.status == AVPlayerItemStatusReadyToPlay){
        return(_currentItem.duration);
    }
    return(kCMTimeInvalid);
}

- (NSTimeInterval)duration
{
    return CMTimeGetSeconds(self.playerItemDuration);
}

- (NSTimeInterval)currentTime
{
    return CMTimeGetSeconds(_currentItem.currentTime);
}

- (BOOL)isPaused
{
    return _metaPlayer.rate == 0.0;
}

- (BOOL)isPlayable
{
    return _currentItem == _metaPlayer.currentItem;
}

+ (NSArray *)observerKeyPathArray
{
    if (!_observerKeyPathArray) {
        _observerKeyPathArray = @[@"status",@"loadedTimeRanges",@"playbackBufferEmpty"/* 缓冲区空了，需要等待数据*/,@"playbackLikelyToKeepUp"/* 缓冲区有足够数据可以播放了*/];
    }
    return _observerKeyPathArray;
}


@end
