//
//  YCNormalVideoCell.m
//  YCPlayerManager
//
//  Created by Durand on 4/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCNormalVideoCell.h"
#import "YCNormalCellDataModel.h"

@interface YCNormalVideoCell ()
@property (nonatomic, strong, readwrite) YCVideoContentView *playerView;
@end

@implementation YCNormalVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.playerView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _playerView.frame = self.contentView.bounds;
}

- (YCVideoContentView *)playerView
{
    if (!_playerView) {
        _playerView = [[YCVideoContentView alloc] init];
    }
    return _playerView;
}

@end
