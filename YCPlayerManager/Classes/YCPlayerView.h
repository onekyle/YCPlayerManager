//
//  YCPlayerView.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@class YCMediaPlayer,AVPlayerLayer;
@protocol YCPlayerViewComponentDelegate <NSObject>

@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;

@property (nonatomic, weak) id<YCPlayerViewEventControlDelegate> eventControl;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

/** 播放暂停按钮*/
@property (nonatomic, strong, nullable) UIButton    *playerControlBtn;

/** 播放显示*/
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
@property (nonatomic, strong) UISlider       *progressSlider;
/** 缓存显示条*/
@property (nonatomic, strong) UIProgressView *loadingProgress;

/** 时间显示label*/
@property (nonatomic, strong) UILabel        *leftTimeLabel;
@property (nonatomic, strong) UILabel        *rightTimeLabel;

/** 时间文字显示格式*/
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@required
/**
 *  设置当前播放按钮状态
 *
 *  @param Paused 是否为暂停状态
 */
- (void)setPlayerControlStatusPaused:(BOOL)Paused;

/**
 *  更新YCPlayerView的布局
 *
 *  @param frame 新的frame
 */
- (void)setUpLayoutWithFrame:(CGRect)frame;

- (void)changeToSuspendTypeWithFrame:(CGRect)suspendFrame;

/**
 *  更新缓冲进度
 *
 *  @param currentLoaderTime 当前加载到的时间
 *  @param duration          资源总共时长
 */
- (void)updateBufferingProgressWithCurrentLoadedTime:(NSTimeInterval)currentLoadedTime duration:(NSTimeInterval)duration;

@end

@interface YCPlayerView : UIView <YCPlayerViewComponentDelegate>

@end

NS_ASSUME_NONNULL_END
