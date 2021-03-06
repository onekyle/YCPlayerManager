//
//  YCPlayerView.m
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayerView.h"
#import "YCPlayer.h"



struct YCPlayerViewDelegateFlags {
    unsigned int clickPlayerControlBtn : 1;
    unsigned int clickCloseBtn : 1;
    unsigned int clickProgressSlider : 1;
    unsigned int tapProgressSlider : 1;
};
typedef struct YCPlayerViewDelegateFlags YCPlayerViewDelegateFlags;

@interface YCPlayerView ()
{
    BOOL _isResponsingSlider;
}
@property (nonatomic, assign) YCPlayerViewDelegateFlags delegateFlags;
@property (nonatomic, assign, readwrite) BOOL isProgerssSliderActivity;
@end

@implementation YCPlayerView
#pragma mark - Synthesize
// 在使用协议中property的时候 只会生成get和set 方法, 所以遵守协议的类需要使用@synthesize生成相应的成员变量
// 如果本类的父类遵守了这种协议, 本类又需要重写在该协议中的某property, 则也需要在本类中使用@synthesize 来指向本类的成员变量
@synthesize player = _player;
@synthesize playerStatus = _playerStatus;
@synthesize eventControl = _eventControl;
@synthesize currentTime = _currentTime;
@synthesize duration = _duration;

@synthesize playerControlBtn = _playerControlBtn;
@synthesize playerLayer = _playerLayer;
@synthesize loadingView = _loadingView;
@synthesize closeBtn = _closeBtn;
@synthesize bottomView = _bottomView;
@synthesize topView = _topView;
@synthesize titleLabel = _titleLabel;
@synthesize progressSlider = _progressSlider;
@synthesize isProgerssSliderActivity = _isProgerssSliderActivity;
@synthesize loadingProgress = _loadingProgress;
@synthesize leftTimeLabel = _leftTimeLabel;
@synthesize rightTimeLabel = _rightTimeLabel;
#pragma mark -

#pragma mark - LifeCycle
- (instancetype)initWithplayer:(YCPlayer *)player
{
    self = [super init];
    if (self) {
        self.player = player;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setUpLayoutWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
        [self setUpLayoutWithFrame:self.frame];
    }
    return self;
}
#pragma mark -

#pragma mark - UI&Layout
- (void)setupUI
{
    [self addSubview:self.loadingView];
    
    //添加顶部视图
    [self addSubview:self.topView];
    
    [self.topView addSubview:self.closeBtn];
    
    //标题
    [self.topView addSubview:self.titleLabel];
    
    //添加底部视图
    [self addSubview:self.bottomView];
    
    //添加暂停和开启按钮
    [self.bottomView addSubview:self.playerControlBtn];
    
    [self.bottomView addSubview:self.progressSlider];
    
    //loadingProgress
    [self.bottomView insertSubview:self.loadingProgress belowSubview:self.progressSlider];
    
    [self.bottomView addSubview:self.leftTimeLabel];
    
    [self.bottomView addSubview:self.rightTimeLabel];
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame)) {
        super.frame = frame;
        [self setUpLayoutWithFrame:frame];
    }
}

- (void)setUpLayoutWithFrame:(CGRect)frame
{
    CGFloat w,h;
    w = frame.size.width;
    h = frame.size.height;
    self.playerLayer.frame = CGRectMake(0, 0, w, h);
    self.frame = frame;
    self.loadingView.center = self.center;
    
    CGFloat topViewW = w;
    CGFloat topViewH = 40;
    self.topView.frame = CGRectMake(0, 0, topViewW, topViewH);
    
    CGFloat titleLabelW = topViewW - 90;
    CGFloat titleLabelH = topViewH;
    self.titleLabel.frame = CGRectMake((topViewW - titleLabelW) / 2, (topViewH - titleLabelH) / 2, titleLabelW, titleLabelH);
    
    self.closeBtn.frame = CGRectMake(5, 5, 30, 30);
    
    CGFloat bottomViewH = 40;
    CGFloat bottomViewW = w;
    self.bottomView.frame = CGRectMake(0, h - bottomViewH, bottomViewW , bottomViewH);
    
    self.playerControlBtn.frame = CGRectMake(0, CGRectGetHeight(self.bottomView.frame) - 40, 40, 40);
    
    CGFloat progressSliderDefaultH = self.progressSlider.frame.size.height;
    CGFloat progressSliderW = bottomViewW - 90;
    CGRect progressSliderFrame = CGRectMake((bottomViewW - progressSliderW) / 2, (bottomViewH - progressSliderDefaultH) / 2, progressSliderW, progressSliderDefaultH);
    self.progressSlider.frame = progressSliderFrame;
    
    CGFloat loadingProgressH = 2;
    // x + 2 , w - 2, 是为了修复系统的UIbug. 既: 在loadingProgress和progressSlider的x值一致的情况下, loadingProgress会比progressSlider的进度条偏左.
    self.loadingProgress.frame = CGRectMake(progressSliderFrame.origin.x + 2,progressSliderFrame.origin.y + (progressSliderFrame.size.height - loadingProgressH) / 2, progressSliderFrame.size.width - 2, loadingProgressH);
    
    CGFloat timeLabelW = bottomViewW - 90;
    CGFloat timeLabelH = 20;
    self.leftTimeLabel.frame = CGRectMake((bottomViewW - titleLabelW) / 2, bottomViewH - timeLabelH, timeLabelW, timeLabelH);
    self.rightTimeLabel.frame = CGRectMake((bottomViewW - titleLabelW) / 2, bottomViewH - timeLabelH, timeLabelW, timeLabelH);
    
    [self bringSubviewToFront:self.loadingView];
}
#pragma mark -

- (void)setEventControl:(id<YCPlayerViewEventControlDelegate>)eventControl
{
    _eventControl = eventControl;
    if ([eventControl conformsToProtocol:@protocol(YCPlayerViewEventControlDelegate)]) {
        _delegateFlags.clickPlayerControlBtn = [eventControl respondsToSelector:@selector(didClickPlayerViewPlayerControlButton:)];
        _delegateFlags.clickCloseBtn = [eventControl respondsToSelector:@selector(didClickPlayerViewCloseButton:)];
        _delegateFlags.clickProgressSlider = [eventControl respondsToSelector:@selector(didClickPlayerViewProgressSlider:)];
        _delegateFlags.tapProgressSlider = [eventControl respondsToSelector:@selector(didTapPlayerViewProgressSlider:)];
    } else {
        _delegateFlags.clickPlayerControlBtn = NO;
        _delegateFlags.clickCloseBtn = NO;
        _delegateFlags.clickProgressSlider = NO;
        _delegateFlags.tapProgressSlider = NO;
    }
}

#pragma mark - UIEventRelated
- (void)resetPlayerView
{
    [self removeFromSuperview];
    //    self.eventControl = nil;
}

- (void)setPlayer:(YCPlayer *)player
{
    _player = player;
    [self.playerLayer removeFromSuperlayer];
    [player.currentLayer removeFromSuperlayer];
    self.playerLayer = player.currentLayer;
    self.playerLayer.frame = self.layer.bounds;
    [self.layer insertSublayer:_playerLayer atIndex:0];
}

- (void)setPlayerStatus:(YCPlayerStatus)playerStatus
{
    switch (playerStatus) {
        case YCPlayerStatusFailed:
            [self.loadingView stopAnimating];
            [self setPlayerControlStatusPaused:YES];
            break;
        case YCPlayerStatustransitioning:
            [self.loadingView startAnimating];
            self.duration = 0.001;
            self.currentTime = 0.0;
            [self.playerLayer removeFromSuperlayer];
            [self setPlayerControlStatusPaused:YES];
            break;
        case YCPlayerStatusBuffering:
            [self.loadingView startAnimating];
            [self setPlayerControlStatusPaused:YES];
            break;
        case YCPlayerStatusReadyToPlay:
            self.duration = self.player.duration;
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                if (!self.player.isPaused) {
                    [self setPlayerControlStatusPaused:NO];
                }
            }
            break;
        case YCPlayerStatusPlaying:
            [self.loadingView stopAnimating];
            if (!self.player.isPaused) {
                [self setPlayerControlStatusPaused:NO];
            }
            break;
        case YCPlayerStatusPause:
            if (_playerStatus == YCPlayerStatusReadyToPlay) {
                [self.loadingView startAnimating];
            }
            [self setPlayerControlStatusPaused:YES];
            break;
        case YCPlayerStatusStopped:
            [self.loadingView stopAnimating];
            [self setPlayerControlStatusPaused:YES];
            break;
        case YCPlayerStatusFinished:
            [self setPlayerControlStatusPaused:YES];
            break;
        default:
            break;
    }
    _playerStatus = playerStatus;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    [self setCurrentTimeTextWithTime:currentTime];
    [self updatePlayingProgressValue:currentTime / self.duration];
}

- (void)setCurrentTimeTextWithTime:(NSTimeInterval)currentTime
{
    self.leftTimeLabel.text = [self changeToStringByTime:currentTime];
}

- (void)setDuration:(NSTimeInterval)duration
{
    if (!duration) {
        return;
    }
    if (isnan(duration)) {
        _duration = 0.001;
    } else {
        _duration = duration;
    }
    self.progressSlider.userInteractionEnabled = _duration > 0.01;
    [self setDurationTimeTextWithTime:_duration];
}

- (void)setDurationTimeTextWithTime:(NSTimeInterval)durationTime
{
    self.rightTimeLabel.text = [self changeToStringByTime:durationTime];
}

- (void)updatePlayingProgressValue:(float)value
{
    if (!_isProgerssSliderActivity) {
        self.progressSlider.value = value;
    }
}

- (void)setPlayerControlStatusPaused:(BOOL)Paused
{
    self.playerControlBtn.selected = Paused;
}

- (void)didStartDragProgressSlider:(UISlider *)sender
{
    _isProgerssSliderActivity = YES;
    _isResponsingSlider = YES;
}

- (void)didClickProgressSlider:(UISlider *)sender
{
    if (!_isResponsingSlider) {
        return;
    }
    if (_delegateFlags.clickProgressSlider) {
        _isProgerssSliderActivity = YES;
        [self.eventControl didClickPlayerViewProgressSlider:sender];
        _isResponsingSlider = NO;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isProgerssSliderActivity = NO;
    });
}

- (void)didTapProgerssSlider:(UIGestureRecognizer *)tap
{
    if (_isResponsingSlider) {
        return;
    }
    _isProgerssSliderActivity = YES;
    CGPoint touchLocation = [tap locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];
    if (_delegateFlags.tapProgressSlider) {
        [self.eventControl didTapPlayerViewProgressSlider:self.progressSlider];
        _isResponsingSlider = NO;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isProgerssSliderActivity = NO;
    });
}

- (void)didClickPlayerControlButton:(UIButton *)sender
{
    if (_delegateFlags.clickPlayerControlBtn) {
        [self.eventControl didClickPlayerViewPlayerControlButton:sender];
    }
}

- (void)colseTheVideo:(UIButton *)sender
{
    if (_delegateFlags.clickCloseBtn) {
        [self.eventControl didClickPlayerViewCloseButton:sender];
    }
}

- (void)updateBufferingProgressWithCurrentLoadedTime:(NSTimeInterval)currentLoadedTime duration:(NSTimeInterval)duration
{
    [self.loadingProgress setProgress:currentLoadedTime/duration animated:NO];
}
#pragma mark -

#pragma mark - HelperMethod
- (NSBundle *)currentBundle
{
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"YCPlayerManager" withExtension:@"bundle"];
    NSBundle *bundle = nil;
    if (bundleURL) {
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    return bundle;
}

- (UIImage *)imageWithImageName:(NSString *)imageName
{
    int scale =  [UIScreen mainScreen].scale;
    NSString *scaleSuffix = [NSString stringWithFormat:@"@%dx",scale];
    if (![imageName hasSuffix:scaleSuffix]) {
        imageName = [imageName stringByAppendingString:scaleSuffix];
    }
    return [UIImage imageWithContentsOfFile:[self.currentBundle pathForResource:imageName ofType:@"png"]];
}

- (UILabel *)labelWithTextAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

- (NSString *)changeToStringByTime:(CGFloat)second{
    NSInteger time = (NSInteger)second;
    if (time / 3600 > 0) { // 时分秒
        NSInteger hour   = time / 3600;
        NSInteger minute = (time % 3600) / 60;
        NSInteger second = (time % 3600) % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, minute, second];
    }else { // 分秒
        NSInteger minute = time / 60;
        NSInteger second = time % 60;
        
        return [NSString stringWithFormat:@"%02zd:%02zd", minute, second];
    }
}
#pragma mark -

#pragma mark - LazyLoad
- (UIButton *)playerControlBtn
{
    if (!_playerControlBtn) {
        _playerControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playerControlBtn.showsTouchWhenHighlighted = YES;
        [_playerControlBtn setImage:[self imageWithImageName:@"player_pause_nor"] forState:UIControlStateNormal];
        [_playerControlBtn setImage:[self imageWithImageName:@"player_play_nor"] forState:UIControlStateSelected];
        _playerControlBtn.selected = YES;
        [_playerControlBtn addTarget:self action:@selector(didClickPlayerControlButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerControlBtn;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loadingView;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    }
    return _topView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[self imageWithImageName:@"player_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [self labelWithTextAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] fontSize:17];
        _titleLabel.text = @"testTitle";
    }
    return _titleLabel;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    }
    return _bottomView;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc]init];
        _progressSlider.minimumValue = 0.0;
        [_progressSlider setThumbImage:[self imageWithImageName:@"player_slider_pos"] forState:UIControlStateNormal];
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        _progressSlider.value = 0.0;//指定初始值
        
        UITapGestureRecognizer *progerssSliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProgerssSlider:)];
        [_progressSlider addGestureRecognizer:progerssSliderTap];
        [_progressSlider addTarget:self action:@selector(didStartDragProgressSlider:)  forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(didClickProgressSlider:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        
        
        _progressSlider.backgroundColor = [UIColor clearColor];
    }
    return _progressSlider;
}

- (UIProgressView *)loadingProgress
{
    if (!_loadingProgress) {
        _loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingProgress.progressTintColor = [UIColor lightGrayColor];
        _loadingProgress.trackTintColor    = [UIColor clearColor];
        [_loadingProgress setProgress:0.0 animated:NO];
    }
    return _loadingProgress;
}

- (UILabel *)leftTimeLabel
{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [self labelWithTextAlignment:NSTextAlignmentLeft textColor:[UIColor whiteColor] fontSize:11];
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel
{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [self labelWithTextAlignment:NSTextAlignmentRight textColor:[UIColor whiteColor] fontSize:11];
    }
    return _rightTimeLabel;
}
#pragma mark -
@end
