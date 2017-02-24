//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCMediaPlayer.h>

@interface YCViewController ()
@property (nonatomic, strong) YCMediaPlayer *player;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _player = [[YCMediaPlayer alloc] initWithMediaURLString:@"http://movies.apple.com/media/us/iphone/2010/tours/apple-iphone4-design_video-us-20100607_848x480.mov"];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player.player];
    playerLayer.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width);
    [self.view.layer addSublayer:playerLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
