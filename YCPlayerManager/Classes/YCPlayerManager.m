//
//  YCPlayerManager.m
//  Pods
//
//  Created by Durand on 27/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayerManager.h"

NSString *const kYCPlayerStatusChangeNotificationKey = @"kYCPlayerStatusChangeNotificationKey";

@interface YCPlayerManager () <YCPlayerViewEventControlDelegate>

@property (nonatomic, copy) NSString *pausedMediaURLString;
@property (nonatomic, copy) void (^completionHandler)();

- (AVPlayer *)metaPlayer;
- (BOOL)hasPausedByManual;
@end

@implementation YCPlayerManager

#pragma mark - LifeCycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerView removeFromSuperview];
    self.playerView.player = nil;
    self.playerView = nil;
    _player = nil;
}

static YCPlayerManager *playerManager;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[self alloc] init];
    });
    return playerManager;
}

- (instancetype)init
{
    return [self initWithplayer:nil playerView:nil];
}


- (instancetype)initWithplayer:(nullable YCPlayer *)player playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView
{
    self = [super init];
    if (self) {
        
        if (!player) {
            player = [[YCPlayer alloc] init];
        }
        _player = player;
        _player.playerDelegate = self;
        if (!playerView) {
            playerView = [[YCPlayerView alloc] init];
        }
        _playerView = playerView;
        _playerView.eventControl = self;
        [self addAllObserver];
    }
    return self;
}
#pragma mark -

#pragma mark - ControlEvent

- (void)playWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void (^)())completionHandler
{
    [self playWithMediaURLString:mediaURLString completionHandler:completionHandler equivalentHandler:nil];
}

- (void)playWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void (^)())completionHandler equivalentHandler:(nullable void (^)())equivalentHandler
{
    if (![_mediaURLString isEqualToString:mediaURLString]) {
        _mediaURLString = [mediaURLString copy];
        _pausedMediaURLString = nil;
        if (mediaURLString) {
            [_player reset];
            _player = [[YCPlayer alloc] init];
            _player.playerDelegate = self;
            _playerView.player = _player;
        }
        //        self.player.mediaURLString = _mediaURLString;
        __weak typeof(self) weakSelf = self;
        _completionHandler = ^{
            [weakSelf resetPlayerLayer];
            if (completionHandler) {
                completionHandler();
            }
        };
        [self.player startPlayingWithMediaURLString:_mediaURLString completionHandler:nil];
    } else {
        if (equivalentHandler) {
            equivalentHandler();
        }
    }
}

- (void)resetPlayerLayer
{
    self.playerView.player = self.player;
}

- (void)play
{
    if (!self.isControllable) {
        return;
    }
    if ([self currentTime] == [self duration]) {
        self.playerView.currentTime = 0.f;
    }
//    [self.playerView setPlayerControlStatusPaused:NO];
    self.pausedMediaURLString = nil;
    [self.metaPlayer play];
}

- (void)pause
{
//    [self.playerView setPlayerControlStatusPaused:YES];
    if (!self.isControllable) {
        return;
    }
    _pausedMediaURLString = _mediaURLString;
    [self.metaPlayer pause];
}

- (void)stop
{
    self.metaPlayer.rate = 0.0;
    _completionHandler = nil;
    self.pausedMediaURLString = nil;
    self.mediaURLString = nil;
    self.player.mediaURLString = nil;
    self.player.status = YCPlayerStatusStopped;
}
    
- (void)seekToTime:(NSTimeInterval)targetTime
{
    if (targetTime >= 0 && targetTime < self.duration) {
        [self.player.currentItem cancelPendingSeeks];
        [self.metaPlayer seekToTime:CMTimeMakeWithSeconds(targetTime, self.player.currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (BOOL)isPaused
{
    return self.metaPlayer.rate == 0.0;
}

- (BOOL)isControllable
{
    return  self.player.status == YCPlayerStatusStopped || (self.player.status != YCPlayerStatustransitioning && self.player.isPlayable);
}
#pragma mark -

#pragma mark - YCPlayerViewEventControlDelegate
- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender
{
    if (self.metaPlayer.rate == 0.0) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)didClickPlayerViewCloseButton:(UIButton *)sender
{

}

- (void)didClickPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player.currentItem cancelPendingSeeks];
    [self.metaPlayer seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.player.currentItem.currentTime.timescale)];
}

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player.currentItem cancelPendingSeeks];
    [self.metaPlayer seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.player.currentItem.currentTime.timescale)];
    if (self.isPaused == 0.f) {
        [self play];
    }
}
#pragma mark -

- (BOOL)playerIsPlayingURLString:(NSString *)URLString
{
    return [_mediaURLString isEqualToString:URLString] && !self.isPaused;
}

#pragma mark - YCPlayerDelegate

/** 播放进度*/
- (void)player:(YCPlayer *)player playPeriodicTimeChangeTo:(CMTime)currentTime
{
    _playerView.currentTime = CMTimeGetSeconds(currentTime);
}
/** 缓存进度*/
- (void)player:(YCPlayer *)player bufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration
{
    // 当缓冲超过俩秒 就自动开始播放
    if (self.player.status == YCPlayerStatusBuffering || self.player.status == YCPlayerStatustransitioning || (self.player.status == YCPlayerStatusPause && !self.hasPausedByManual)) {
        if (loadedTime - self.currentTime > 2.0) {
            [self play];
        }
    }
}
/** 播放状态*/
- (void)player:(YCPlayer *)player didChangeToStatus:(YCPlayerStatus)status fromStatus:(YCPlayerStatus)fromStatus
{
    if ([NSThread currentThread].isMainThread) {
        self.playerView.playerStatus = status;
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.playerView.playerStatus = status;
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kYCPlayerStatusChangeNotificationKey object:nil userInfo:@{@"toStatus": @(status)}];
    if (status == YCPlayerStatusReadyToPlay && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        if (!self.hasPausedByManual) {
            [player.metaPlayer play];
            if (_completionHandler) {
                _completionHandler();
                _completionHandler = nil;
            }
        }
    } else if (fromStatus == YCPlayerStatusBuffering && status == YCPlayerStatusPlaying) {
        if (_completionHandler) {
            if (!self.hasPausedByManual) {
                [player.metaPlayer play];
                if (_completionHandler) {
                    _completionHandler();
                    _completionHandler = nil;
                }
            }
        } else if (!self.hasPausedByManual) {
            [self play];
        }
    } else if (status == YCPlayerStatusFailed && fromStatus == YCPlayerStatustransitioning) {
        [self stop];
    }
}
#pragma mark -

#pragma mark - GlobalNotication
- (void)addAllObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionInterruptionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeInactive:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)onAudioSessionInterruptionEvent:(NSNotification *)noti
{
    self.player.hasCorrectFalg = NO;
    [self pause];
}

- (void)onAudioSessionRouteChange:(NSNotification *)noti
{
    AVAudioSessionRouteChangeReason reason = [noti.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (reason == AVAudioSessionRouteChangeReasonOverride) {
        return;
    }
    
    self.player.hasCorrectFalg = NO;
    [self pause];
}

- (void)onBecomeActive:(NSNotification *)noti
{
    self.player.hasCorrectFalg = NO;
//    [self pause];
}

- (void)onBecomeInactive:(NSNotification *)noti
 {
     if (self.enableBackgroundPlay) {
         if (!self.isPaused) {
             self.player.hasCorrectFalg = YES;
             float version = [UIDevice currentDevice].systemVersion.floatValue;
             if (version < 9.0) {
                 [self.player performSelector:@selector(setHasCorrectFalg:) withObject:@(NO) afterDelay:1.5];
             } else if (version >= 11.0) {
                 [self.player.metaPlayer performSelector:@selector(playWithoutChangeStatus) withObject:nil afterDelay:0.01];
             }
         }
     } else {
         [self pause];
     }
 }

#pragma mark -

#pragma mark - Setter
- (void)setPlayerView:(UIView<YCPlayerViewComponentDelegate> *)playerView
{
    if (_playerView != playerView) {
//        [_playerView removeFromSuperview];
        [_playerView resetPlayerView];
        _playerView = playerView;
        _playerView.eventControl = self;
        _playerView.player = _player;
    }
}

- (void)setMediaURLString:(NSString *)mediaURLString
{
    if (![_mediaURLString isEqualToString:mediaURLString]) {
        _mediaURLString = [mediaURLString copy];
        self.pausedMediaURLString = nil;
        
//        self.player.mediaURLString = _mediaURLString;
        __weak typeof(self) weakSelf = self;
        _completionHandler = ^{
            weakSelf.playerView.player = weakSelf.player;
        };
        [self.player startPlayingWithMediaURLString:_mediaURLString completionHandler:nil];
    }
}
#pragma mark -

#pragma mark - Getter
- (AVPlayer *)metaPlayer
{
    return _player.metaPlayer;
}

- (NSTimeInterval)currentTime
{
    if (self.player.status == YCPlayerStatustransitioning) {
        return 0.0;
    }
    return self.player.currentTime;
}

- (NSTimeInterval)duration
{
    return self.player.duration;
}

- (BOOL)hasPausedByManual
{
    return [_pausedMediaURLString isEqualToString:_mediaURLString];
}
#pragma mark -

- (NSString *)ycStatusDescription:(YCPlayerStatus)status
{
    NSString *desc = nil;
    switch (status) {
        case YCPlayerStatusFailed:
            desc = @"YCPlayerStatusFailed";
            break;
        case YCPlayerStatusUnKnown:
            desc = @"YCPlayerStatusUnKnown";
            break;
        case YCPlayerStatustransitioning:
            desc = @"YCPlayerStatustransitioning";
            break;
        case YCPlayerStatusBuffering:
            desc = @"YCPlayerStatusBuffering";
            break;
        case YCPlayerStatusReadyToPlay:
            desc = @"YCPlayerStatusReadyToPlay";
            break;
        case YCPlayerStatusPlaying:
            desc = @"YCPlayerStatusPlaying";
            break;
        case YCPlayerStatusPause:
            desc = @"YCPlayerStatusPause";
            break;
        case YCPlayerStatusStopped:
            desc = @"YCPlayerStatusStopped";
            break;
        case YCPlayerStatusFinished:
            desc = @"YCPlayerStatusFinished";
            break;
        default:
            desc = @"NoOne";
            break;
    }
    return desc;
}
@end


