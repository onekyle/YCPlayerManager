//
//  YCMediaPlayerDelegate.h
//  YCPlayerManager
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#ifndef YCMediaPlayerDelegate_h
#define YCMediaPlayerDelegate_h


@class YCMediaPlayer;
@protocol YCMediaPlayerDelegate <NSObject>

@optional
/** 播放进度*/
- (void)mediaPlayerPlayPeriodicTimeChange:(YCMediaPlayer *)mediaPlayer;
///播放状态
/** 播放失败的代理方法*/
- (void)mediaPlayerFailedPlay:(YCMediaPlayer *)mediaPlayer;
/** 正在缓冲的代理方法*/
- (void)mediaPlayerBuffering:(YCMediaPlayer *)mediaPlayer;
/** 准备播放的代理方法*/
- (void)mediaPlayerReadyToPlay:(YCMediaPlayer *)mediaPlayer;
/** 播放完毕的代理方法*/
- (void)mediaPlayerFinishPlay:(YCMediaPlayer *)mediaPlayer;

@end

#endif /* YCMediaPlayerDelegate_h */
