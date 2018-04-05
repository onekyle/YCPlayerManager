//
//  YCPlayerView.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  UI控件的事件代理.
 */
@protocol YCPlayerViewEventControlDelegate <NSObject>

- (void)didClickPlayerViewPlayerControlButton:(UIButton *)sender;

- (void)didClickPlayerViewCloseButton:(UIButton *)sender;

- (void)didClickPlayerViewProgressSlider:(UISlider *)sender;

- (void)didTapPlayerViewProgressSlider:(UISlider *)sender;
@end

@class YCPlayer,AVPlayerLayer;
@protocol YCPlayerViewComponentDelegate <NSObject>

@optional
@property (nonatomic, strong, nullable) YCPlayer *player;

@property (nonatomic, assign) YCPlayerStatus playerStatus;

@property (nonatomic, weak) id<YCPlayerViewEventControlDelegate> eventControl;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

/** 播放暂停按钮*/
@property (nonatomic, strong, nullable) UIButton    *playerControlBtn;

/** 播放显示*/
@property (nonatomic, weak) AVPlayerLayer *playerLayer;

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
@property (nonatomic, strong) UISlider       *progressSlider;
/** 进度条是否正在响应*/
@property (nonatomic, assign, readonly) BOOL isProgerssSliderActivity;
/** 缓存显示条*/
@property (nonatomic, strong) UIProgressView *loadingProgress;

/** 时间显示label*/
@property (nonatomic, strong) UILabel        *leftTimeLabel;
@property (nonatomic, strong) UILabel        *rightTimeLabel;

/** 时间文字显示格式*/
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@required

- (void)resetPlayerView;

// UIComponent target selector
/** 开始拖拽*/
- (void)didStartDragProgressSlider:(UISlider *)sender;

/** 拖拽了(拖拽完成调用)进度条*/
- (void)didClickProgressSlider:(UISlider *)sender;

/** 点击了进度条*/
- (void)didTapProgerssSlider:(UIGestureRecognizer *)tap;

/** 点击了 播放/暂停 按钮*/
- (void)didClickPlayerControlButton:(UIButton *)sender;

- (void)colseTheVideo:(UIButton *)sender;


/**
 *  在下面俩个方法中,默认更新相应的显示时间的label.公开出来是适应某些特殊显示需求.
 */

- (void)setCurrentTimeTextWithTime:(NSTimeInterval)currentTime;

- (void)setDurationTimeTextWithTime:(NSTimeInterval)durationTime;
/**
 *  设置当前播放按钮状态
 *
 *  @param Paused 是否为暂停状态
 */
- (void)setPlayerControlStatusPaused:(BOOL)Paused;

/**
 *  初始化视图
 *
 */
- (void)setupUI;

/**
 *  更新YCPlayerView的布局
 *
 *  @param frame 新的frame
 */
- (void)setUpLayoutWithFrame:(CGRect)frame;


/**
 *  更新缓冲进度
 *
 *  @param currentLoadedTime 当前加载到的时间
 *  @param duration          资源总共时长
 */
- (void)updateBufferingProgressWithCurrentLoadedTime:(NSTimeInterval)currentLoadedTime duration:(NSTimeInterval)duration;

@end

@interface YCPlayerView : UIView <YCPlayerViewComponentDelegate>

@end

NS_ASSUME_NONNULL_END
