//
//  YCPlayerDelegate.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#ifndef YCPlayerDelegate_h
#define YCPlayerDelegate_h


// 播放器的几种状态
typedef NS_ENUM(NSInteger, YCPlayerStatus) {
    /** 播放失败*/
    YCPlayerStatusFailed = -1,
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
- (void)playerPlayPeriodicTimeChange:(YCPlayer *)player;
/** 缓存进度*/
- (void)playerBufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration;
///播放状态
- (void)playerPlay:(YCPlayer *)player statusChanged:(YCPlayerStatus)status;

@end

#endif /* YCPlayerDelegate_h */
