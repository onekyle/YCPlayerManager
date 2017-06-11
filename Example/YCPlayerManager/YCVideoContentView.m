//
//  YCVideoContentView.m
//  YCPlayerManager
//
//  Created by Durand on 11/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCVideoContentView.h"


@interface YCSliderNode : UISlider

@end

@implementation YCSliderNode

// 如果thunmb的图片很大 如果恰巧有透明的部分, 那么就会显示出来.
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    // 修改thumbe的bounds宽度 不会影响它的宽度,只会影响其在x轴上的偏移
    bounds.size.width = 0;
    // 计算x坐标
    bounds.origin.x = rect.size.width * value;
    return bounds;
}
@end


@implementation YCVideoContentView
@synthesize bottomView = _bottomView;
@synthesize progressSlider = _progressSlider;
@synthesize playerControlBtn = _playerControlBtn;
@synthesize leftTimeLabel = _leftTimeLabel;

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    [super setCurrentTime:currentTime];
}

- (void)setCurrentTimeTextWithTime:(NSTimeInterval)currentTime
{
    self.leftTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",[self formatSeconds:currentTime],_durationString];
}

- (void)setDurationTimeTextWithTime:(NSTimeInterval)durationTime
{
    _durationString = [self formatSeconds:durationTime];
}

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

- (void)setupUI
{
    [super setupUI];
    [self insertSubview:self.placeholderImageView atIndex:0];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDoubleTimes)];
    //    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)setUpLayoutWithFrame:(CGRect)frame
{
    CGFloat w,h;
    w = frame.size.width;
    h = frame.size.height;
    
    self.placeholderImageView.frame = CGRectMake(0, 0, w, h);
    
    self.playerLayer.frame = CGRectMake(0, 0, w, h);
    self.frame = frame;
    self.loadingView.center = self.center;
    
    [self updateBottomViewFrame:frame];
    
    [self bringSubviewToFront:self.loadingView];
    
}

- (void)updateBottomViewFrame:(CGRect)frame
{
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    CGFloat bottomViewH = 45;
    CGFloat bottomViewW = w;
    self.bottomView.frame = CGRectMake(0, h - bottomViewH, bottomViewW , bottomViewH);
    
    CGFloat bottomBackImgVH = 45;
    self.bottomBackImgV.frame = CGRectMake(0, h - bottomBackImgVH, bottomViewW, bottomBackImgVH);
    
    CGFloat playerControlBtnW = 40;
    self.playerControlBtn.frame = CGRectMake(0, (bottomViewH - playerControlBtnW) / 2 + 1, playerControlBtnW, playerControlBtnW);
    
    CGFloat timeLabelW = 80;
    CGFloat timeLabelH = 18;
    //    CGFloat timeLabelTopMargin = 20;
    CGFloat timeLabelRightMargin = 20;
    CGFloat timeLabelX = bottomViewW - timeLabelW - timeLabelRightMargin;
    self.leftTimeLabel.frame = CGRectMake(timeLabelX, (bottomViewH - timeLabelH) / 2, timeLabelW, timeLabelH);
    
    CGFloat progressSliderX = playerControlBtnW + 5;
    //    CGFloat progressSliderY = 14;
    CGFloat progressSliderDefaultH = self.progressSlider.frame.size.height;
    CGFloat progressSliderW = timeLabelX - progressSliderX;
    CGRect progressSliderFrame = CGRectMake(progressSliderX, (bottomViewH - progressSliderDefaultH) / 2,  progressSliderW, progressSliderDefaultH);
    self.progressSlider.frame = progressSliderFrame;
    
    //    CGFloat loadingProgressH = 2;
    //    // x + 2 , w - 2, 是为了修复系统的UIbug. 既: 在loadingProgress和progressSlider的x值一致的情况下, loadingProgress会比progressSlider的进度条偏左.
    //    self.loadingProgress.frame = CGRectMake(progressSliderFrame.origin.x + 2,progressSliderFrame.origin.y + (progressSliderFrame.size.height - loadingProgressH) / 2, progressSliderFrame.size.width - 2, loadingProgressH);
}

- (void)didTapDoubleTimes
{
    [YCPlayerManager shareManager].isPaused ? [[YCPlayerManager shareManager] play] : [[YCPlayerManager shareManager] pause];
}

- (UIView *)topView
{
    return nil;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (UIImageView *)bottomBackImgV
{
    if (!_bottomBackImgV) {
        _bottomBackImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playView_Nav_Down_BackImage"]];
        [self insertSubview:_bottomBackImgV belowSubview:self.bottomView];
    }
    return _bottomBackImgV;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[YCSliderNode alloc]init];
        _progressSlider.minimumValue = 0.0;
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        _progressSlider.value = 0.0;//指定初始值
        
        UITapGestureRecognizer *progerssSliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProgerssSlider:)];
        [_progressSlider addGestureRecognizer:progerssSliderTap];
        [_progressSlider addTarget:self action:@selector(didStartDragProgressSlider:)  forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(didClickProgressSlider:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        _progressSlider.backgroundColor = [UIColor clearColor];
        
        UIImage *minImg = [UIImage imageNamed:@"录歌_彩色进度条"];
        UIImage *maxImg = [UIImage imageNamed:@"playerView_Slider_white"];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"activity_silder_dot"] forState:UIControlStateNormal];
        
        [_progressSlider setMinimumTrackImage:minImg forState:UIControlStateNormal];
        [_progressSlider setMaximumTrackImage:maxImg forState:UIControlStateNormal];
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"activity_silder_dot"] forState:UIControlStateDisabled];
        [_progressSlider setMinimumTrackImage:minImg forState:UIControlStateDisabled];
        [_progressSlider setMaximumTrackImage:maxImg forState:UIControlStateDisabled];
        
    }
    return _progressSlider;
}

- (UIButton *)playerControlBtn
{
    if (!_playerControlBtn) {
        _playerControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playerControlBtn setImage:[UIImage imageNamed:@"录歌_播放器暂停"] forState:UIControlStateNormal];
        [_playerControlBtn setImage:[UIImage imageNamed:@"录歌_播放器开始"] forState:UIControlStateSelected];
        _playerControlBtn.selected = YES;
        [_playerControlBtn addTarget:self action:@selector(didClickPlayerControlButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerControlBtn;
}

- (UILabel *)leftTimeLabel
{
    if (!_leftTimeLabel) {
        _leftTimeLabel  = [[UILabel alloc] init];
        _leftTimeLabel.textAlignment = NSTextAlignmentRight;
        _leftTimeLabel.font = [UIFont systemFontOfSize:10];
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.text = @"00:00 / 00:00";
    }
    return _leftTimeLabel;
}


- (UIImageView *)placeholderImageView
{
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _placeholderImageView;
}

- (UILabel *)rightTimeLabel
{
    return nil;
}

- (UIProgressView *)loadingProgress
{
    return nil;
}

@end



