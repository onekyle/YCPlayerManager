//
//  YCPlayerView.m
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayerView.h"
#import "YCMediaPlayer.h"

@interface YCPlayerView ()

/** 菊花加载框*/
@property (nonatomic, strong) UIActivityIndicatorView   *loadingView;

/** 底部操作工具视图*/
@property (nonatomic, strong) UIView    *bottomView;

/** 顶部操作工具视图*/
@property (nonatomic, strong) UIView    *topView;

/** 显示播放视频的title*/
@property (nonatomic, strong) UILabel   *titleLabel;

/** 播放暂停按钮*/
@property (nonatomic, strong, nullable) UIButton    *playerControlBtn;
@end

@implementation YCPlayerView

- (instancetype)initWithMediaPlayer:(YCMediaPlayer *)mediaPlayer
{
    self = [super init];
    if (self) {
        _mediaPlayer = mediaPlayer;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpUI];
    }
    return self;
}

- (void)_setUpUI
{
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.loadingView];
    
    //添加顶部视图
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.topView];
    
    //添加底部视图
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.bottomView];
    
    //添加暂停和开启按钮
    self.playerControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playerControlBtn.showsTouchWhenHighlighted = YES;
//    self.playerControlBtn setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
//    [self.playerControlBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
}


@end
