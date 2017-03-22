//
//  YCMediaPlayer.m
//  Pods
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCMediaPlayer.h"

@interface _YCPlayer : AVPlayer
@property (nonatomic, weak) YCMediaPlayer *mediaPlayer;
@end

@implementation _YCPlayer

- (void)pause
{
    [super pause];
    self.mediaPlayer.status = YCMediaPlayerStatusPause;
}

- (void)play
{
    [super play];
    self.mediaPlayer.status = YCMediaPlayerStatusPlaying;
}


@end

static void *MediPlayerStatusObservationContext = &MediPlayerStatusObservationContext;

@interface YCMediaPlayer ()
{
    _YCPlayer *_player;
}
/** 监听播放进度的timer*/
@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation YCMediaPlayer

- (void)reset
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    
    [self.player removeTimeObserver:self.playbackTimeObserver];
    //移除观察者
    [_currentItem removeObserver:self forKeyPath:@"status"];
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    _currentItem = nil;
    [_currentLayer removeFromSuperlayer];
    _currentLayer = nil;
}

- (void)dealloc
{
    [self reset];
}

- (instancetype)initWithMediaURLString:(NSString *)mediaURLString
{
    self = [super init];
    if (self) {
        [self setMediaURLString:mediaURLString];
    }
    return self;
}

- (void)setMediaURLString:(NSString *)mediaURLString
{
    _mediaURLString = mediaURLString;
    [self setCurrentItem:[self getPlayItemWithURLString:mediaURLString]];
    if (!self.player && _currentItem) {
        _player = [[_YCPlayer alloc] initWithPlayerItem:_currentItem];
        _player.mediaPlayer = self;
        _player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
        _currentLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    }
    self.status = YCMediaPlayerStatusBuffering;
}

- (void)setCurrentItem:(AVPlayerItem *)currentItem
{
    if (_currentItem == currentItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        @try {
            [self.player removeTimeObserver:self.playbackTimeObserver];
        } @catch (NSException *exception) {
            NSLog(@"func: %s, exception: %@",__func__,exception);
        }
        
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _currentItem = nil;
    }
    _currentItem = currentItem;
    if (_currentItem) {
        [_currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionNew
                          context:MediPlayerStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:MediPlayerStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:MediPlayerStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:MediPlayerStatusObservationContext];
        
        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        _currentLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)url
{
    if (!url.length) {
        return nil;
    }
    if ([url containsString:@"http"]) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    } else {
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:url] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
}

- (void)addMediaPlayerPlayProgressTimeObserver
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    if (self.playbackTimeObserver) {
        @try {
            [self.player removeTimeObserver:self.playbackTimeObserver];
        } @catch (NSException *exception) {
            NSLog(@"func: %s, exception: %@",__func__,exception);
        }
    }
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [weakSelf.player
                                  addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)
                                  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
                                  usingBlock:^(CMTime time){
                                      if ([weakSelf playerDelegateCanCall:@selector(mediaPlayerPlayPeriodicTimeChange:)]) {
                                          [weakSelf.playerDelegate mediaPlayerPlayPeriodicTimeChange:weakSelf];
                                      }
                                                                          }];
}

- (void)moviePlayDidEnd:(NSNotification *)notification
{
//    [self.player removeTimeObserver:self.playbackTimeObserver];
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
    self.status = YCMediaPlayerStatusFinished;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == MediPlayerStatusObservationContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            [self handleChangeAboutAVPlayerStatus:status];
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval currentLoadedTime = [self availableDuration];
            NSTimeInterval duration       = CMTimeGetSeconds(self.currentItem.duration);
            if ([self playerDelegateCanCall:@selector(mediaPlayerBufferingWithCurrentLoadedTime:duration:)]) {
                [self.playerDelegate mediaPlayerBufferingWithCurrentLoadedTime:currentLoadedTime duration:duration];
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.currentItem.isPlaybackBufferEmpty) {
                self.status = YCMediaPlayerStatusBuffering;
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.currentItem.isPlaybackLikelyToKeepUp && (self.status == YCMediaPlayerStatusBuffering || self.status == YCMediaPlayerStatusFailed)){
                self.status = YCMediaPlayerStatusPlaying;
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
    
- (void)handleChangeAboutAVPlayerStatus:(AVPlayerStatus)status
{
    switch (status) {
        case AVPlayerStatusUnknown:
        {
            self.status = YCMediaPlayerStatusBuffering;
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            if (self.status != YCMediaPlayerStatusReadyToPlay) {
                self.status = YCMediaPlayerStatusReadyToPlay;
                [self addMediaPlayerPlayProgressTimeObserver];
            }
            /* Once the AVPlayerItem becomes ready to play, i.e.
             [playerItem status] == AVPlayerItemStatusReadyToPlay,
             its duration can be fetched from the item. */
        }
            break;
            
        case AVPlayerStatusFailed:
        {
            self.status = YCMediaPlayerStatusFailed;
        }
            break;
        default:
            break;
    }
}

- (void)setStatus:(YCMediaPlayerStatus)status
{
    _status = status;
    if ([self playerDelegateCanCall:@selector(mediaPlayerPlay:statusChanged:)]) {
        [self.playerDelegate mediaPlayerPlay:self statusChanged:status];
    }
}

    
    
    
- (BOOL)playerDelegateCanCall:(SEL)method
{
    return [self.playerDelegate conformsToProtocol:@protocol(YCMediaPlayerDelegate)] && [self.playerDelegate respondsToSelector:method];
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

@end
