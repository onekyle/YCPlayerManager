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

- (void)play
{
    [super play];
    self.owner.status = YCPlayerStatusPlaying;
}


@end

static void *YCPlayerStatusObservationContext = &YCPlayerStatusObservationContext;
static NSArray *_observerKeyPathArray = nil;

@interface YCPlayer ()
{
    _YCPrivatePlayer *_metaPlayer;
}

/** 监听播放进度的timer*/
@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation YCPlayer
@synthesize metaPlayer = _metaPlayer;

- (instancetype)initWithMediaURLString:(NSString *)mediaURLString
{
    self = [super init];
    if (self) {
        [self setMediaURLString:mediaURLString];
    }
    return self;
}

- (void)dealloc
{
    [self reset];
}

- (void)setMediaURLString:(NSString *)mediaURLString
{
    _mediaURLString = mediaURLString;
    [self setCurrentItem:[self getPlayItemWithURLString:mediaURLString]];
    if (!_metaPlayer && _currentItem) {
        _metaPlayer = [[_YCPrivatePlayer alloc] initWithPlayerItem:_currentItem];
        _metaPlayer.owner = self;
        _metaPlayer.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        _currentLayer = [AVPlayerLayer playerLayerWithPlayer:_metaPlayer];
    }
    if (mediaURLString) {
        self.status = YCPlayerStatusBuffering;
    }
}

- (void)setCurrentItem:(AVPlayerItem *)currentItem
{
    if (_currentItem == currentItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        @try {
            [self.metaPlayer removeTimeObserver:self.playbackTimeObserver];
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
        
        [self.metaPlayer replaceCurrentItemWithPlayerItem:_currentItem];
        _currentLayer = [AVPlayerLayer playerLayerWithPlayer:self.metaPlayer];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}

- (void)setStatus:(YCPlayerStatus)status
{
    _status = status;
    if ([self playerDelegateCanCall:@selector(playerPlay:statusChanged:)]) {
        [self.playerDelegate playerPlay:self statusChanged:status];
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
    [self.metaPlayer.currentItem cancelPendingSeeks];
    [self.metaPlayer.currentItem.asset cancelLoading];
    [self.metaPlayer pause];
    
    [self.metaPlayer removeTimeObserver:self.playbackTimeObserver];
    //移除观察者
    for (NSString *keyPathStr in [YCPlayer observerKeyPathArray]) {
        [_currentItem removeObserver:self forKeyPath:keyPathStr];
    }
    
    [self.metaPlayer replaceCurrentItemWithPlayerItem:nil];
    _metaPlayer = nil;
    _currentItem = nil;
    [_currentLayer removeFromSuperlayer];
    _currentLayer = nil;
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)url
{
    if (!url.length) {
        return nil;
    }
    if ([url rangeOfString:@"http"].location != NSNotFound) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    } else {
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:url] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
}

- (void)addplayerPlayProgressTimeObserver
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    if (self.playbackTimeObserver) {
        @try {
            [self.metaPlayer removeTimeObserver:self.playbackTimeObserver];
        } @catch (NSException *exception) {
            NSLog(@"func: %s, exception: %@",__func__,exception);
        }
    }
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [weakSelf.metaPlayer
                                  addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)
                                  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
                                  usingBlock:^(CMTime time){
                                      if ([weakSelf playerDelegateCanCall:@selector(playerPlayPeriodicTimeChange:)]) {
                                          [weakSelf.playerDelegate playerPlayPeriodicTimeChange:weakSelf];
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
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            [self handleChangeAboutAVPlayerStatus:status];
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval currentLoadedTime = [self availableDuration];
            NSTimeInterval duration       = CMTimeGetSeconds(self.currentItem.duration);
            if ([self playerDelegateCanCall:@selector(playerBufferingWithCurrentLoadedTime:duration:)]) {
                [self.playerDelegate playerBufferingWithCurrentLoadedTime:currentLoadedTime duration:duration];
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
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


- (BOOL)playerDelegateCanCall:(SEL)method
{
    return [self.playerDelegate conformsToProtocol:@protocol(YCPlayerDelegate)] && [self.playerDelegate respondsToSelector:method];
}

- (CMTime)playerItemDuration{
    if (_currentItem.status == AVPlayerItemStatusReadyToPlay){
        return([_currentItem duration]);
    }
    return(kCMTimeInvalid);
}

- (NSTimeInterval)duration
{
    return CMTimeGetSeconds(self.playerItemDuration);
}

+ (NSArray *)observerKeyPathArray
{
    if (!_observerKeyPathArray) {
        _observerKeyPathArray = @[@"status",@"loadedTimeRanges",@"playbackBufferEmpty"/* 缓冲区空了，需要等待数据*/,@"playbackLikelyToKeepUp"/* 缓冲区有足够数据可以播放了*/];
    }
    return _observerKeyPathArray;
}


@end
