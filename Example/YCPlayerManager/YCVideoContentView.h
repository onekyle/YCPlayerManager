//
//  YCVideoContentView.h
//  YCPlayerManager
//
//  Created by Durand on 11/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <YCPlayerManager/YCPlayerManager.h>

@interface YCVideoContentView : YCPlayerView
@property (nonatomic, strong) NSString *durationString;
@property (nonatomic, strong) UIImageView *bottomBackImgV;
@property (nonatomic, strong) UIImageView *placeholderImageView;

@end
