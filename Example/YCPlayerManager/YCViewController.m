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

@interface YCViewController () <YCMediaPlayerDelegate>
@property (nonatomic, strong) YCMediaPlayer *player;
@property (nonatomic, strong) YCPlayerView *playerView;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _player = [[YCMediaPlayer alloc] initWithMediaURLString:@"http://movies.apple.com/media/us/iphone/2010/tours/apple-iphone4-design_video-us-20100607_848x480.mov"];
    _player.playerDelegate = self;
    _playerView = [[YCPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20)];
    _playerView.mediaPlayer = _player;
    _playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

@end
