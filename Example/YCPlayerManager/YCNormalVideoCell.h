//
//  YCNormalVideoCell.h
//  YCPlayerManager
//
//  Created by Durand on 4/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCVideoContentView.h"

@interface YCNormalVideoCell : UITableViewCell
@property (nonatomic, strong, readonly) YCVideoContentView *playerView;
@end
