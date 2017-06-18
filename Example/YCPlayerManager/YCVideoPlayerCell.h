//
//  YCVideoPlayerCell.h
//  YCPlayerManager
//
//  Created by Durand on 24/3/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCVideoCellDataModel.h"

@interface YCVideoPlayerCell : UITableViewCell
@property (nonatomic, strong) YCVideoCellDataModel *data;
@property (nonatomic, assign) BOOL show;

+ (CGFloat)cellHeight;
- (void)playVideo;
- (void)makeCellActivity;
- (void)resetActivityCell;
@end
