//
//  YCPlayerDelegate.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#ifndef YCPlayerDelegate_h
#define YCPlayerDelegate_h

#import <AVFoundation/AVFoundation.h>

// 播放器的几种状态
typedef NS_ENUM(NSInteger, YCPlayerStatus) {
    /** 播放失败*/
    YCPlayerStatusFailed = -1,
    /** 初始化*/
    YCPlayerStatusUnKnown = 0,
    /** 切换播放源中, 一般用于移除旧视图, 将时间及各种状态复位*/
    YCPlayerStatustransitioning,
    /** 缓冲中*/
    YCPlayerStatusBuffering,
    /** 将要播放*/
    YCPlayerStatusReadyToPlay,
    /** 播放中*/
    YCPlayerStatusPlaying,
    /** 暂停*/
    YCPlayerStatusPause,
    /** 停止播放*/
    YCPlayerStatusStopped,
    /** 播放完毕*/
    YCPlayerStatusFinished
};

@class YCPlayer;
@protocol YCPlayerDelegate <NSObject>

@optional

/** 播放进度*/
- (void)player:(YCPlayer *)player playPeriodicTimeChangeTo:(CMTime)currentTime;
/** 缓存进度*/
- (void)player:(YCPlayer *)player bufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration;
/** 播放状态*/
- (void)player:(YCPlayer *)player didChangeToStatus:(YCPlayerStatus)status fromStatus:(YCPlayerStatus)fromStatus;

@end

#endif /* YCPlayerDelegate_h */
