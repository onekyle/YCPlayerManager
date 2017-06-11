//
//  DemoManager.m
//  YCPlayerManager
//
//  Created by Durand on 11/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "DemoManager.h"

@implementation DemoManager
static DemoManager *_manager = nil;
 + (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        _manager.enableBackgroundPlay = YES;
    });
    return _manager;
}

@end
