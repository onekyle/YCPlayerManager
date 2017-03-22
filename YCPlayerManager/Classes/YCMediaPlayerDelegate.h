//
//  YCMediaPlayerDelegate.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#ifndef YCMediaPlayerDelegate_h
#define YCMediaPlayerDelegate_h


// 播放器的几种状态
typedef NS_ENUM(NSInteger, YCMediaPlayerStatus) {
    YCMediaPlayerStatusFailed = 1,      // 播放失败
    YCMediaPlayerStatusBuffering,       // 缓冲中
    YCMediaPlayerStatusReadyToPlay,     // 将要播放
    YCMediaPlayerStatusPlaying,     // 播放中
    YCMediaPlayerStatusPause,       //暂停播放
    YCMediaPlayerStatusStopped,     // 停止播放
    YCMediaPlayerStatusFinished     //播放完毕
};

@class YCMediaPlayer;
@protocol YCMediaPlayerDelegate <NSObject>

@optional

/** 播放进度*/
- (void)mediaPlayerPlayPeriodicTimeChange:(YCMediaPlayer *)mediaPlayer;
/** 缓存进度*/
- (void)mediaPlayerBufferingWithCurrentLoadedTime:(NSTimeInterval)loadedTime duration:(NSTimeInterval)duration;
///播放状态
- (void)mediaPlayerPlay:(YCMediaPlayer *)mediaPlayer statusChanged:(YCMediaPlayerStatus)status;

@end

#endif /* YCMediaPlayerDelegate_h */
