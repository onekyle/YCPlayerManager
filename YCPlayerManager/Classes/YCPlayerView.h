//
//  YCPlayerView.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCPlayerViewDelegate <NSObject>



@end

@class YCMediaPlayer;
@interface YCPlayerView : UIView

@property (nonatomic, strong) YCMediaPlayer *mediaPlayer;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

@end
