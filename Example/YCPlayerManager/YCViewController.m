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

@interface YCViewController () <YCMediaPlayerDelegate,YCPlayerViewEventControlDelegate>
@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;
@property (nonatomic, strong) YCPlayerView *playerView;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mediaPlayer = [[YCMediaPlayer alloc] initWithMediaURLString:@"http://movies.apple.com/media/us/iphone/2010/tours/apple-iphone4-design_video-us-20100607_848x480.mov"];
    _mediaPlayer.playerDelegate = self;
    _playerView = [[YCPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20)];
    _playerView.mediaPlayer = _mediaPlayer;
    _playerView.backgroundColor = [UIColor blackColor];
    _playerView.eventControl = self;
    [self.view addSubview:_playerView];
}

#pragma mark - YCPlayerViewEventControlDelegate
- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender
{
    if (self.player.rate != 1.f) {
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
    NSLog(@"didClickPlayerViewCloseButton");
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
        self.playerView.playerControlBtn.selected = NO;
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
    NSLog(@"nowtime: %f",nowTime);
}
///播放状态
/** 播放失败的代理方法*/
- (void)mediaPlayerFailedPlay:(YCMediaPlayer *)mediaPlayer
{
    NSLog(@"mediaPlayerFailedPlay");
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
}
/** 播放完毕的代理方法*/
- (void)mediaPlayerFinishPlay:(YCMediaPlayer *)mediaPlayer
{
    NSLog(@"mediaPlayerFinishPlay");
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
