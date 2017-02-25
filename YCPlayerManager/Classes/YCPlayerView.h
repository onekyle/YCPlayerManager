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

@class YCMediaPlayer;
@interface YCPlayerView : UIView

@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;

@property (nonatomic, weak) id<YCPlayerViewEventControlDelegate> eventControl;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

/** 播放暂停按钮*/
@property (nonatomic, strong, nullable) UIButton    *playerControlBtn;

- (void)setPlayerControlStatusPaused:(BOOL)Paused;

@end
