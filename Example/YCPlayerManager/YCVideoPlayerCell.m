//
//  YCVideoPlayerCell.m
//  YCPlayerManager
//
//  Created by Durand on 24/3/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCVideoPlayerCell.h"

@interface YCVideoPlayerCell ()
@property (nonatomic, strong) CALayer *coverLayer;
@end

@implementation YCVideoPlayerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self _setUpUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _coverLayer.frame = self.contentView.bounds;
}


- (void)_setUpUI
{
    _coverLayer = ({
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor blackColor].CGColor;
        layer.opacity = 0.6;
        layer;
    });
    [self.contentView.layer addSublayer:_coverLayer];
}
@end
