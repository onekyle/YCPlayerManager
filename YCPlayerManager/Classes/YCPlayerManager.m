//
//  YCPlayerManager.m
//  Pods
//
//  Created by Durand on 27/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayerManager.h"

NSString *const kYCPlayerStatusChangeNotificationKey = @"kYCPlayerStatusChangeNotificationKey";

@interface YCPlayerManager () <YCPlayerDelegate,YCPlayerViewEventControlDelegate>

- (AVPlayer *)player;
@end

@implementation YCPlayerManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerView removeFromSuperview];
    self.playerView.mediaPlayer = nil;
    self.playerView = nil;
    _mediaPlayer = nil;
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
    return [self initWithMediaPlayer:nil playerView:nil];
}

- (instancetype)initWithMediaPlayer:(nullable YCPlayer *)mediaPlayer playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView
{
    self = [super init];
    if (self) {
 
        if (!mediaPlayer) {
            mediaPlayer = [[YCPlayer alloc] init];
        }
        _mediaPlayer = mediaPlayer;
        _mediaPlayer.playerDelegate = self;
        if (!playerView) {
            playerView = [[YCPlayerView alloc] init];
        }
        _playerView = playerView;
        _playerView.eventControl = self;
        [self addAllObserver];
    }
    return self;
}

- (void)addAllObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionInterruptionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeInactive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setPlayerView:(UIView<YCPlayerViewComponentDelegate> *)playerView
{
    if (_playerView != playerView) {
        [_playerView removeFromSuperview];
        _playerView = playerView;
        _playerView.eventControl = self;
        _playerView.mediaPlayer = _mediaPlayer;
    }
}

- (void)setMediaURLString:(NSString *)mediaURLString
{
    if (![_mediaURLString isEqualToString:mediaURLString]) {
        _mediaURLString = [mediaURLString copy];
        self.mediaPlayer.mediaURLString = _mediaURLString;
        self.playerView.mediaPlayer = self.mediaPlayer;
    }
}

- (void)play
{
    if ([self currentTime] == [self duration]) {
        [self.playerView setCurrentTime:0.f];
    }
//    [self.playerView setPlayerControlStatusPaused:NO];
    [self.player play];
}

- (void)pause
{
//    [self.playerView setPlayerControlStatusPaused:YES];
    [self.player pause];
}

- (void)stop
{
    [self.player setRate:0.0];
    self.mediaURLString = nil;
    self.mediaPlayer.mediaURLString = nil;
    [self mediaPlayerPlay:self.mediaPlayer statusChanged:YCPlayerStatusStopped];
}

- (BOOL)isPaused
{
    return self.player.rate == 0.0;
}

#pragma mark - YCPlayerViewEventControlDelegate
- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender
{
    if (self.player.rate == 0.0) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)didClickPlayerViewCloseButton:(UIButton *)sender
{
    //    NSLog(@"didClickPlayerViewCloseButton");
//    [self showSmallScreen];
}

- (void)didClickPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player.currentItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.mediaPlayer.currentItem.currentTime.timescale)];
}

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player.currentItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.mediaPlayer.currentItem.currentTime.timescale)];
    if (self.player.rate == 0.f) {
        [self play];
    }
}
#pragma mark -


#pragma mark - YCPlayerDelegate
/** 播放进度*/
- (void)mediaPlayerPlayPeriodicTimeChange:(YCPlayer *)player
{
    Float64 nowTime = CMTimeGetSeconds([player.player currentTime]);
    _playerView.currentTime = nowTime;
}

- (void)mediaPlayerBufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration
{
    [self.playerView updateBufferingProgressWithCurrentLoadedTime:loadedTime duration:duration];
}

- (void)mediaPlayerPlay:(YCPlayer *)mediaPlayer statusChanged:(YCPlayerStatus)status
{
    if (status == YCPlayerStatusReadyToPlay && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [mediaPlayer.player play];
    }
    
    self.playerView.playerStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:kYCPlayerStatusChangeNotificationKey object:nil userInfo:@{@"toStatus": @(status)}];
}


#pragma mark - GlobalNotication
- (void)onAudioSessionInterruptionEvent:(NSNotification *)noti
{
    self.mediaPlayer.hasCorrectFalg = NO;
    [self pause];
}

- (void)onAudioSessionRouteChange:(NSNotification *)noti
{
    self.mediaPlayer.hasCorrectFalg = NO;
    [self pause];
}

- (void)onBecomeActive:(NSNotification *)noti
{
    self.mediaPlayer.hasCorrectFalg = NO;
//    [self pause];
}

- (void)onBecomeInactive:(NSNotification *)noti
 {
     if (self.enableBackgroundPlay) {
         self.mediaPlayer.hasCorrectFalg = YES;
         [self.mediaPlayer performSelector:@selector(setHasCorrectFalg:) withObject:@(NO) afterDelay:1];
     } else {
         [self pause];
     }
 }

#pragma mark -

- (AVPlayer *)player
{
    return _mediaPlayer.player;
}

- (NSTimeInterval)currentTime
{
    return CMTimeGetSeconds([self.player currentTime]);
}

- (NSTimeInterval)duration
{
    return self.mediaPlayer.duration;
}

@end


