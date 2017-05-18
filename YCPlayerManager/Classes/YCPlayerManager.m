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
- (AVPlayer *)metaPlayer;
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
- (void)play
{
    if ([self currentTime] == [self duration]) {
        self.playerView.currentTime = 0.f;
    }
//    [self.playerView setPlayerControlStatusPaused:NO];
    [self.metaPlayer play];
}

- (void)pause
{
//    [self.playerView setPlayerControlStatusPaused:YES];
    [self.metaPlayer pause];
}

- (void)stop
{
    self.metaPlayer.rate = 0.0;
    self.mediaURLString = nil;
    self.player.mediaURLString = nil;
    [self player:self.player didChangeStatus:YCPlayerStatusStopped];
}

- (BOOL)isPaused
{
    return self.metaPlayer.rate == 0.0;
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
    Float64 seconds = sender.value * self.duration;
    NSLog(@"seconds : %.3f, value: %.3f, sender: %d-1111111",seconds,sender.value, sender.tracking);
    [self.metaPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.player.currentItem.currentTime.timescale)];
}

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player.currentItem cancelPendingSeeks];
    Float64 seconds = sender.value * self.duration;
    NSLog(@"seconds : %.3f, value: %.3f, sender: %d-2222222",seconds,sender.value, sender.tracking);
    [self.metaPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.player.currentItem.currentTime.timescale)];
    if (self.metaPlayer.rate == 0.f) {
        [self play];
    }
}
#pragma mark -

- (BOOL)playerIsPlayingURLString:(NSString *)URLString
{
    return [self.mediaURLString isEqualToString:URLString] && !self.isPaused;
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
    [self.playerView updateBufferingProgressWithCurrentLoadedTime:loadedTime duration:duration];
}
/** 播放状态*/
- (void)player:(YCPlayer *)player didChangeStatus:(YCPlayerStatus)status
{
    if (status == YCPlayerStatusReadyToPlay && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [player.metaPlayer play];
    }
    
    self.playerView.playerStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:kYCPlayerStatusChangeNotificationKey object:nil userInfo:@{@"toStatus": @(status)}];
}
#pragma mark -

#pragma mark - GlobalNotication
- (void)addAllObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionInterruptionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeInactive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onAudioSessionInterruptionEvent:(NSNotification *)noti
{
    self.player.hasCorrectFalg = NO;
    [self pause];
}

- (void)onAudioSessionRouteChange:(NSNotification *)noti
{
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
         self.player.hasCorrectFalg = YES;
         [self.player performSelector:@selector(setHasCorrectFalg:) withObject:@(NO) afterDelay:1];
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
        self.player.mediaURLString = _mediaURLString;
        self.playerView.player = self.player;
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
    return CMTimeGetSeconds([self.metaPlayer currentTime]);
}

- (NSTimeInterval)duration
{
    return self.player.duration;
}
#pragma mark -

@end


