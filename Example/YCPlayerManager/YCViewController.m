//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCPlayerManager.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface YCViewController ()
@property (nonatomic, strong) YCPlayerManager *playerManager;
@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _playerManager = [[YCPlayerManager alloc] init];
    _playerManager.mediaURLString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    _playerManager.playerView.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth);
    [self.view addSubview:_playerManager.playerView];
}

@end
