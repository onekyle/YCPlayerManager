//
//  DemoManager.h
//  YCPlayerManager
//
//  Created by Durand on 11/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <YCPlayerManager/YCPlayerManager.h>
#import "YCVideoPlayerCell.h"
@interface DemoManager : YCPlayerManager

@property (nonatomic, weak) YCVideoPlayerCell *currentActivityCell;

@end
