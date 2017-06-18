//
//  YCVideoPlayerCell.m
//  YCPlayerManager
//
//  Created by Durand on 24/3/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "DemoManager.h"

#import "YCVideoPlayerCell.h"
#import "YCVideoCellHeaderView.h"
#import "YCVideoContentView.h"
#import "UIFont+YCCategory.h"

@interface YCVideoPlayerCell ()
@property (nonatomic, weak) DemoManager *playerManager;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) YCVideoCellHeaderView *headerView;
@property (nonatomic, strong) UIImageView *videoContainerView;
@property (nonatomic, strong) UIButton *controlButton;
//@property (nonatomic, strong) YCVideoContentView *videoView;
@property (nonatomic, strong) UILabel *detailInfoLabel;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) CALayer *coverLayer;
@end

@implementation YCVideoPlayerCell

#define kVideoContentHeight (ceil(9.0 / 16.0 * kScreenWidth) + 30)
CGFloat kHeaderHeight = 70;
CGFloat kDetailInfoHeight = 70;
CGFloat kSeparatoHeight = 15;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self _setUpUI];
    }
    return self;
}

- (void)setData:(YCVideoCellDataModel *)data
{
    _data = data;
    [_headerView.userIconView sd_setImageWithURL:[NSURL URLWithString:data.provider.icon] placeholderImage:nil];
    if (data.category.length) {
        _headerView.userNameLabel.text = [NSString stringWithFormat:@"%@ #%@",data.provider.name, data.category];
    } else {
        _headerView.userNameLabel.text = data.provider.name;
    }
    
    
    [_backImageView sd_setImageWithURL:[NSURL URLWithString:data.cover.blurred]];
    [_videoContainerView sd_setImageWithURL:[NSURL URLWithString:data.cover.feed]];
    
    if ([_playerManager.mediaURLString isEqualToString:data.playUrl]) {
        [self makeCellActivity];
        _controlButton.hidden = YES;
    } else {
        [self resetActivityCell];
    }
    
    _detailInfoLabel.text = data.detail;
}

- (void)playVideo
{
    [self didClickCoverPauseBtn];
}

- (void)setShow:(BOOL)show
{
    if (_show != show) {
        _show = show;
        if (show) {
            _coverLayer.opacity = 0.0;
        } else {
            _coverLayer.opacity = 0.8;
        }
    }
}

- (void)makeCellActivity
{
    [self createPlayerViewIfNeedForSuperView:_videoContainerView needAdd:YES];
    _playerManager.currentActivityCell = self;
    _playerManager.playerView.duration = _playerManager.duration;
    _playerManager.playerView.currentTime = _playerManager.currentTime;
    _playerManager.playerView.playerControlStatusPaused = _playerManager.isPaused;
}

- (void)resetActivityCell
{
    if ([_playerManager.playerView.superview isEqual:_videoContainerView]) {
        [_playerManager.playerView resetPlayerView];
    }
    _controlButton.hidden = NO;
}

- (void)didClickCoverPauseBtn
{
    // 1.将播放视图添加到当前cell的playerContainerView中, 并记录是否改变了视图类型
    BOOL hasChangeStyleFlag = [self createPlayerViewIfNeedForSuperView:self.videoContainerView needAdd:NO];
    // 2.播放状态及属性的设置.
    if (![_playerManager.mediaURLString isEqualToString:self.data.playUrl]) {
        // 播放新的要将属性复位.
        _playerManager.playerView.duration = 0.001;
        _playerManager.playerView.currentTime = 0.0;
        _playerManager.playerView.playerControlStatusPaused = _playerManager.isPaused;
    } else {
        // 将要播放的与上一个相同, 则将属性同步.
        _playerManager.playerView.duration = _playerManager.duration;
        _playerManager.playerView.currentTime = _playerManager.currentTime;
        _playerManager.playerView.playerControlStatusPaused = _playerManager.isPaused;
        if (_playerManager.isPaused) {
            [_playerManager play];
        }
    }
    
    // 3.记录当前播放的cell 用于视图切换时 做相关优化处理(界面无缝同步)
    _playerManager.currentActivityCell = self;
    UIImageView *playerViewPlaceholder = ((YCVideoContentView *)self.playerManager.playerView).placeholderImageView;
    playerViewPlaceholder.image = self.videoContainerView.image;
    [self.videoContainerView addSubview:self.playerManager.playerView];
    
    // 4.开始播放, 将这一步放在判断之外, 是得益于YCPlayerManager内部对于相同播放源不处理的原因.
    __weak typeof(self) weakSelf = self;
    void (^loadAsssertCallBack)() = ^{
        
        UIImageView *playerViewPlaceholder = ((YCVideoContentView *)weakSelf.playerManager.playerView).placeholderImageView;
        playerViewPlaceholder.image = weakSelf.videoContainerView.image;
        if (weakSelf.playerManager.currentTime < 0.01) {
            //            [weakSelf.playerManager.playerView removeFromSuperview];
            
            playerViewPlaceholder.alpha = 1.0;
        } else {
            playerViewPlaceholder.alpha = 0.0;
        }
        //        [weakSelf.playerContainerView addSubview:weakSelf.playerManager.playerView];
        if (playerViewPlaceholder.alpha > 0.0) {
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
                playerViewPlaceholder.alpha = 0.0;
            } completion:nil];
        }
    };
    
    [_playerManager playWithMediaURLString:self.data.playUrl completionHandler:loadAsssertCallBack equivalentHandler:^{
        if (hasChangeStyleFlag && loadAsssertCallBack) {
            loadAsssertCallBack();
        }
    }];
    _playerManager.playerView.duration = _data.duration;
    _controlButton.hidden = YES;
    
}

- (BOOL)createPlayerViewIfNeedForSuperView:(UIImageView *)superView needAdd:(BOOL)needAddFlag
{
    if (![_playerManager.playerView isMemberOfClass:[YCVideoContentView class]]) {
        YCVideoContentView *playerView = [[YCVideoContentView alloc] init];
        [_playerManager.currentActivityCell resetActivityCell];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        playerView.frame = superView.bounds;
        _playerManager.playerView = playerView;
        _playerManager.player.currentLayer.backgroundColor = [UIColor blackColor].CGColor;
        if (needAddFlag) {
            [superView addSubview:playerView];
        }
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
        return YES;
    } else if (![superView isEqual:_playerManager.playerView.superview]) {
        [_playerManager.currentActivityCell resetActivityCell];
        [_playerManager.playerView resetPlayerView];
        _playerManager.playerView.frame = superView.bounds;
        _playerManager.player.currentLayer.backgroundColor = [UIColor blackColor].CGColor;
        if (needAddFlag) {
            [superView addSubview:_playerManager.playerView];
        }
        return YES;
    }
    return NO;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width;
//    CGFloat height = self.contentView.bounds.size.height;
    _backImageView.frame = self.contentView.bounds;
    _coverLayer.frame = self.contentView.bounds;
    _headerView.frame = CGRectMake(0, 0, width, kHeaderHeight);
    
    _videoContainerView.frame = CGRectMake(0, kHeaderHeight, width, kVideoContentHeight);
    _controlButton.frame = _videoContainerView.frame;
    
    CGFloat detailLabelY = CGRectGetMaxY(_videoContainerView.frame);
    _detailInfoLabel.frame = CGRectMake(15, detailLabelY, width - 15 * 2, kDetailInfoHeight);
    
    CGFloat separatorY = CGRectGetMaxY(_detailInfoLabel.frame);
    _separatorView.frame = CGRectMake(0, separatorY, width, kSeparatoHeight);
}


- (void)_setUpUI
{
    _backImageView = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.backgroundColor = [UIColor blackColor];
        imgView.userInteractionEnabled = YES;
        imgView;
    });
    [self.contentView addSubview:_backImageView];
    
    _headerView = ({
        YCVideoCellHeaderView *view = [[YCVideoCellHeaderView alloc] init];
        view;
    });
    [self.contentView addSubview:_headerView];
    
    _videoContainerView = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        imgView.backgroundColor = [UIColor blackColor];
        imgView.userInteractionEnabled = YES;
        imgView;
    });
    [self.contentView addSubview:_videoContainerView];
    
    _controlButton = ({
        UIButton *btn =[UIButton new];
        [btn setImage:[UIImage imageNamed:@"activity_video_play"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClickCoverPauseBtn) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.contentView addSubview:_controlButton];
    
    
    _detailInfoLabel = ({
        UILabel *lbl = [[UILabel alloc] init];
        lbl.numberOfLines = 0;
        lbl.font = YCFont(kYCFontSize4);
        lbl.textColor = [UIColor blackColor];
        lbl;
    });
    [self.contentView addSubview:_detailInfoLabel];
    
    _separatorView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        view;
    });
    [self.contentView addSubview:_separatorView];
    
    _coverLayer = ({
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor blackColor].CGColor;
        layer.opacity = 0.6;
        layer;
    });
    [self.contentView.layer addSublayer:_coverLayer];
    
    _playerManager = [DemoManager shareManager];
}

+ (CGFloat)cellHeight
{
    return kHeaderHeight + kVideoContentHeight + kDetailInfoHeight + kSeparatoHeight;
}
@end
