//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCMediaPlayer.h>
#import <YCPlayerManager/YCPlayerView.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface YCViewController () <YCMediaPlayerDelegate,YCPlayerViewEventControlDelegate>
@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;
@property (nonatomic, strong) YCPlayerView *playerView;
@property (nonatomic, assign, getter=isSuspending) BOOL suspending;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mediaPlayer = [[YCMediaPlayer alloc] initWithMediaURLString:@"http://flv2.bn.netease.com/videolib3/1609/03/lGPqA9142/SD/lGPqA9142-mobile.mp4"];
    _mediaPlayer.playerDelegate = self;
    
    _playerView = [[YCPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width)];
    _playerView.mediaPlayer = _mediaPlayer;
    _playerView.eventControl = self;
    [self.view addSubview:_playerView];
}

-(void)showSmallScreen{
    
    if (self.isSuspending) {
        [self.playerView removeFromSuperview];
        CGRect bigFrame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width);
        [self.view addSubview:self.playerView];
        [UIView animateWithDuration:0.25 animations:^{
            [self.playerView setUpLayoutWithFrame:bigFrame];
        } completion:^(BOOL finished) {
            
            self.suspending = NO;
        }];
    } else {
        //放widow上
        [self.playerView removeFromSuperview];
        CGFloat width = kScreenWidth/2;
        CGRect suspendFrame = CGRectMake(kScreenWidth - width, 64, width, width);
        [UIView animateWithDuration:0.25 animations:^{
            [self.playerView changeToSuspendTypeWithFrame:suspendFrame];
            [[UIApplication sharedApplication].keyWindow addSubview:self.playerView];
        }completion:^(BOOL finished) {
            self.suspending = YES;
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.playerView];
        }];
    }
}


#pragma mark - YCPlayerViewEventControlDelegate
- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender
{
    if (self.player.rate != 1.0) {
        [self.player currentTime];
        if ([self currentTime] == self.mediaPlayer.duration)
            self.playerView.currentTime = 0.0f;
        sender.selected = NO;
        [self.player play];
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
//    NSLog(@"nowtime: %f",nowTime);
}
///播放状态
/** 播放失败的代理方法*/
- (void)mediaPlayerFailedPlay:(YCMediaPlayer *)mediaPlayer
{
//    NSLog(@"mediaPlayerFailedPlay");
    [self.playerView setPlayerControlStatusPaused:YES];
}
/** 正在缓冲的代理方法*/
- (void)mediaPlayerBuffering:(YCMediaPlayer *)mediaPlayer
{
    NSLog(@"mediaPlayerBuffering");
}
/** 准备播放的代理方法*/
- (void)mediaPlayerReadyToPlay:(YCMediaPlayer *)mediaPlayer
{
    _playerView.duration = mediaPlayer.duration;
    [mediaPlayer.player play];
    [self.playerView setPlayerControlStatusPaused:NO];
}
/** 播放完毕的代理方法*/
- (void)mediaPlayerFinishPlay:(YCMediaPlayer *)mediaPlayer
{
    [self.playerView setPlayerControlStatusPaused:YES];
    NSLog(@"mediaPlayerFinishPlay");
}

- (void)mediaPlayerBufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration
{
    [self.playerView updateBufferingProgressWithCurrentLoadedTime:loadedTime duration:duration];
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
