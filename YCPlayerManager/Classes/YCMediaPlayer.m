//
//  YCMediaPlayer.m
//  Pods
//
//  Created by Durand on 24/2/17.
//
//

#import "YCMediaPlayer.h"

static void *MediPlayerStatusObservationContext = &MediPlayerStatusObservationContext;

@interface YCMediaPlayer ()

/** 监听播放进度的timer*/
@property (nonatomic ,strong) id playbackTimeObserver;

@end

@implementation YCMediaPlayer

-(void)dealloc
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
    if (!self.player) {
        _player = [AVPlayer playerWithPlayerItem:_currentItem];
        _player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
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
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)url
{
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
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [weakSelf.player
                                  addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)
                                  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
                                  usingBlock:^(CMTime time){
                                      [self playerDelegateSafeCallAndPassOn:@selector(mediaPlayerPlayPeriodicTimeChange:)];
                                                                          }];
}

- (void)moviePlayDidEnd:(NSNotification *)notification
{
    self.status = YCMediaPlayerStatusFinished;
    [self.player removeTimeObserver:self.playbackTimeObserver];
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
    }];
    [self playerDelegateSafeCallAndPassOn:@selector(mediaPlayerFinishPlay:)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == MediPlayerStatusObservationContext) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            [self handleChangeAboutAVPlayerStatus:status];
        }
//        else if (<#expression#>) {
//            
//        } else if (<#expression#>) {
//            
//        } else if (<#expression#>) {
//            
//        } else if (<#expression#>) {
//            
//        }
    }
}

- (void)handleChangeAboutAVPlayerStatus:(AVPlayerStatus)status
{
    switch (status) {
        case AVPlayerStatusUnknown:
        {
            self.status = YCMediaPlayerStatusBuffering;
            [self playerDelegateSafeCallAndPassOn:@selector(mediaPlayerBuffering:)];
            
        }
            break;
            
        case AVPlayerStatusReadyToPlay:
        {
            self.status = YCMediaPlayerStatusReadyToPlay;
            [self playerDelegateSafeCallAndPassOn:@selector(mediaPlayerReadyToPlay:)];
            [self addMediaPlayerPlayProgressTimeObserver];
            /* Once the AVPlayerItem becomes ready to play, i.e.
             [playerItem status] == AVPlayerItemStatusReadyToPlay,
             its duration can be fetched from the item. */
        }
            break;
            
        case AVPlayerStatusFailed:
        {
            self.status = YCMediaPlayerStatusFailed;
            [self playerDelegateSafeCallAndPassOn:@selector(mediaPlayerFailedPlay:)];
        }
            break;
        default:
            break;
    }
}

- (void)setStatus:(YCMediaPlayerStatus)status
{
    _status = status;
    
}

- (BOOL)playerDelegateCanCall:(SEL)method
{
    return [self.playerDelegate conformsToProtocol:@protocol(YCMediaPlayerDelegate)] && [self.playerDelegate respondsToSelector:method];
}

- (void)playerDelegateSafeCallAndPassOn:(SEL)method
{
    if ([self playerDelegateCanCall:method]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.playerDelegate performSelector:method withObject:self];
#pragma clang diagnostic pop
    }
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
