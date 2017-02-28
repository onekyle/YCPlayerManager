//
//  YCPlayerManager.m
//  Pods
//
//  Created by Durand on 27/2/17.
//
//

#import "YCPlayerManager.h"

@interface YCPlayerManager () <YCMediaPlayerDelegate,YCPlayerViewEventControlDelegate>

@end

@implementation YCPlayerManager

- (instancetype)init
{
    return [self initWithMediaPlayer:nil playerView:nil];
}

- (instancetype)initWithMediaPlayer:(nullable YCMediaPlayer *)mediaPlayer playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView
{
    self = [super init];
    if (self) {
        if (!mediaPlayer) {
            mediaPlayer = [[YCMediaPlayer alloc] init];
        }
        _mediaPlayer = mediaPlayer;
        _mediaPlayer.playerDelegate = self;
        if (!playerView) {
            playerView = [[YCPlayerView alloc] init];
        }
        _playerView = playerView;
        _playerView.eventControl = self;
    }
    return self;
}

- (void)setPlayerView:(UIView<YCPlayerViewComponentDelegate> *)playerView
{
    if (_playerView != playerView) {
        [_playerView removeFromSuperview];
        _playerView = playerView;
        _playerView.eventControl = self;
        if (self.mediaURLString.length) {
            _playerView.mediaPlayer = _mediaPlayer;
        }
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

-(void)showSmallScreen
{
    
}

#pragma mark - Control
- (void)play
{
    
}

- (void)stop
{
    [self.player setRate:0.0];
    [self mediaPlayerPlay:self statusChanged:YCMediaPlayerStatusFinished];
}

#pragma mark - YCPlayerViewEventControlDelegate
- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender
{
    if (self.player.rate != 1.0) {
        [self.player currentTime];
        if ([self currentTime] == self.mediaPlayer.duration) {
            self.playerView.currentTime = 0.0f;
        }
        [self.player play];
        sender.selected = NO;
    } else {
        sender.selected = YES;
        [self.player pause];
    }
}

- (void)didClickPlayerViewCloseButton:(UIButton *)sender
{
    //    NSLog(@"didClickPlayerViewCloseButton");
    [self showSmallScreen];
}

- (void)didClickPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.mediaPlayer.currentItem.currentTime.timescale)];
}

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender
{
    [self.player seekToTime:CMTimeMakeWithSeconds(sender.value * self.duration, self.mediaPlayer.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self.playerView setCurrentTime:0.f];
        [self.playerView setPlayerControlStatusPaused:NO];
        [self.player play];
    }
}
#pragma mark -


#pragma mark - YCMediaPlayerDelegate
/** 播放进度*/
- (void)mediaPlayerPlayPeriodicTimeChange:(YCMediaPlayer *)mediaPlayer
{
    Float64 nowTime = CMTimeGetSeconds([mediaPlayer.player currentTime]);
    _playerView.currentTime = nowTime;
}

- (void)mediaPlayerBufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration
{
    [self.playerView updateBufferingProgressWithCurrentLoadedTime:loadedTime duration:duration];
}

- (void)mediaPlayerPlay:(YCMediaPlayer *)mediaPlayer statusChanged:(YCMediaPlayerStatus)status
{
    if (status == YCMediaPlayerStatusReadyToPlay) {
        [mediaPlayer.player play];
    }
    self.playerView.playerStatus = status;
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


