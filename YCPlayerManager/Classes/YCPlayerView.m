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
{
    BOOL _isProgerssSliderActivity;
}

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
@end

@implementation YCPlayerView

- (instancetype)initWithMediaPlayer:(YCMediaPlayer *)mediaPlayer
{
    self = [super init];
    if (self) {
        self.mediaPlayer = mediaPlayer;
        [self _setUpUI];
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

- (void)setMediaPlayer:(YCMediaPlayer *)mediaPlayer
{
    _mediaPlayer = mediaPlayer;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:mediaPlayer.player];
    self.playerLayer.frame = self.layer.bounds;
    //视频的默认填充模式，AVLayerVideoGravityResizeAspect
//    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer insertSublayer:_playerLayer atIndex:0];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    self.leftTimeLabel.text = [self changeToStringByTime:currentTime];
    if (!_isProgerssSliderActivity) {
        self.progressSlider.value = currentTime / self.duration;
    }
}

- (void)setDuration:(NSTimeInterval)duration
{
    if (!duration) {
        return;
    }
    _duration = duration;
    self.rightTimeLabel.text = [self changeToStringByTime:duration];
}

- (void)_setUpUI
{
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.loadingView];
    
    //添加顶部视图
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.topView];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[self imageWithImageName:@"player_close"] forState:UIControlStateNormal];
    [self.topView addSubview:self.closeBtn];
    
    //标题
    self.titleLabel = [self labelWithTextAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] fontSize:17];
    self.titleLabel.text = @"testTitle";
    [self.topView addSubview:self.titleLabel];
    
    //添加底部视图
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.bottomView];
    
    //添加暂停和开启按钮
    self.playerControlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playerControlBtn.showsTouchWhenHighlighted = YES;
    [self.playerControlBtn setImage:[self imageWithImageName:@"player_pause_nor"] forState:UIControlStateNormal];
    [self.playerControlBtn setImage:[self imageWithImageName:@"player_play_nor"] forState:UIControlStateSelected];
    [self.playerControlBtn addTarget:self action:@selector(didClickPlayerControlButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView addSubview:self.playerControlBtn];
    
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:[self imageWithImageName:@"player_slider_pos"] forState:UIControlStateNormal];
    self.progressSlider.maximumTrackTintColor = [UIColor clearColor];
    self.progressSlider.value = 0.0;//指定初始值

    [self.progressSlider addTarget:self action:@selector(didStartDragProgressSlider:)  forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(didClickProgressSlider:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *progerssSliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProgerssSlider:)];
    [self.progressSlider addGestureRecognizer:progerssSliderTap];
    
    self.progressSlider.backgroundColor = [UIColor clearColor];
    [self.bottomView addSubview:self.progressSlider];
    
    self.leftTimeLabel = [self labelWithTextAlignment:NSTextAlignmentLeft textColor:[UIColor whiteColor] fontSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    self.rightTimeLabel = [self labelWithTextAlignment:NSTextAlignmentRight textColor:[UIColor whiteColor] fontSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.layer.bounds;
    
    CGFloat w,h;
    w = self.frame.size.width;
    h = self.frame.size.height;
    
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
    self.progressSlider.frame = CGRectMake((bottomViewW - progressSliderW) / 2, (bottomViewH - progressSliderDefaultH) / 2, progressSliderW, progressSliderDefaultH);

    CGFloat timeLabelW = bottomViewW - 90;
    CGFloat timeLabelH = 20;
    self.leftTimeLabel.frame = CGRectMake((bottomViewW - titleLabelW) / 2, bottomViewH - timeLabelH, timeLabelW, timeLabelH);
    self.rightTimeLabel.frame = CGRectMake((bottomViewW - titleLabelW) / 2, bottomViewH - timeLabelH, timeLabelW, timeLabelH);
}

- (void)didStartDragProgressSlider:(UISlider *)sender
{
    _isProgerssSliderActivity = YES;
}

- (void)didClickProgressSlider:(UISlider *)sender
{
    _isProgerssSliderActivity = NO;
    if ([self eventControlCanCall:@selector(didClickPlayerViewProgressSlider:)]) {
        [self.eventControl didClickPlayerViewProgressSlider:sender];
    }
}

- (void)didTapProgerssSlider:(UIGestureRecognizer *)tap
{
    CGPoint touchLocation = [tap locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];
    _isProgerssSliderActivity = NO;
    if ([self eventControlCanCall:@selector(didTapPlayerViewProgressSlider:)]) {
        [self.eventControl didTapPlayerViewProgressSlider:self.progressSlider];
    }
}

- (void)didClickPlayerControlButton:(UIButton *)sender
{
    if ([self eventControlCanCall:@selector(didClickPlayerViewPlayerControlButton:)]) {
        [self.eventControl didClickPlayerViewPlayerControlButton:sender];
    }
}

- (void)colseTheVideo:(UIButton *)sender
{
    if ([self eventControlCanCall:@selector(didClickPlayerViewCloseButton:)]) {
        [self.eventControl didClickPlayerViewCloseButton:sender];
    }
}


- (BOOL)eventControlCanCall:(SEL)method
{
    return [self.eventControl conformsToProtocol:@protocol(YCPlayerViewEventControlDelegate)] && [self.eventControl respondsToSelector:method];
}

- (NSBundle *)currentBundle
{
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"YCPlayerManager" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
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
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

@end
