//
//  YCPlayerView.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCPlayerViewEventControlDelegate <NSObject>

- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender;

- (void)didClickPlayerViewCloseButton:(UIButton *)sender;

- (void)didClickPlayerViewProgressSlider:(UISlider *)sender;

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender;
@end

@class YCMediaPlayer,AVPlayerLayer;
@interface YCPlayerView : UIView

@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;

@property (nonatomic, weak) id<YCPlayerViewEventControlDelegate> eventControl;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

/** 播放暂停按钮*/
@property (nonatomic, strong, nullable) UIButton    *playerControlBtn;


@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/** 菊花加载框*/
@property (nonatomic, strong) UIActivityIndicatorView   *loadingView;

/** 关闭按钮*/
@property (nonatomic, strong) UIButton *closeBtn;

/** 底部操作工具视图*/
@property (nonatomic, strong) UIView    *bottomView;

/** 顶部操作工具视图*/
@property (nonatomic, strong) UIView    *topView;

/** 显示播放视频的title*/
@property (nonatomic, strong) UILabel   *titleLabel;

/** 播放进度*/
@property (nonatomic,strong) UISlider       *progressSlider;

/** 时间显示label*/
@property (nonatomic,strong) UILabel        *leftTimeLabel;
@property (nonatomic,strong) UILabel        *rightTimeLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)setPlayerControlStatusPaused:(BOOL)Paused;

- (void)setUpLayoutWithFrame:(CGRect)frame;

- (void)changeToSuspendTypeWithFrame:(CGRect)suspendFrame;

@end
