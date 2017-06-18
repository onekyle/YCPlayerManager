//
//  YCVideoCellHeaderView.m
//  YCPlayerManager
//
//  Created by Durand on 18/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCVideoCellHeaderView.h"
#import "UIFont+YCCategory.h"

@implementation YCVideoCellHeaderView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self yc_setupUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat topMargin = 15;
    CGFloat leftMargin = 15;
    CGFloat userIconViewW = 40;
    _userIconView.frame = CGRectMake(leftMargin, topMargin, userIconViewW, userIconViewW);
    _userIconView.layer.cornerRadius = userIconViewW / 2;
    
    CGFloat iconTitleMargin = 10;
    CGFloat userNameLabelX = CGRectGetMaxX(_userIconView.frame) + iconTitleMargin;
    CGFloat userNameLabelH = 22;
    CGFloat textMaxWidth = self.bounds.size.width - userNameLabelX - leftMargin;
    _userNameLabel.frame = CGRectMake(userNameLabelX, (self.bounds.size.height - userNameLabelH) / 2, textMaxWidth, userNameLabelH);
}

- (void)yc_setupUI
{
    _userIconView = [[UIImageView alloc] init];
    _userIconView.layer.masksToBounds = YES;
    _userIconView.contentMode = UIViewContentModeScaleAspectFill;
    _userIconView.userInteractionEnabled = YES;
    [self addSubview:_userIconView];
    
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.font = YCFont(kYCFontSize3);
    _userNameLabel.textColor = [UIColor blackColor];
    _userNameLabel.textAlignment = NSTextAlignmentLeft;
    _userNameLabel.userInteractionEnabled = YES;
    [self addSubview:_userNameLabel];
}

@end
