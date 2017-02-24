//
//  YCMediaPlayer.h
//  Pods
//
//  Created by Durand on 24/2/17.
//
//

NS_ASSUME_NONNULL_BEGIN

@import AVFoundation;

// 播放器的几种状态
typedef NS_ENUM(NSInteger, YCMediaPlayerStatus) {
    YCMediaPlayerStatusFailed,        // 播放失败
    YCMediaPlayerStatusBuffering,     // 缓冲中
    YCMediaPlayerStatusReadyToPlay,  // 将要播放
    YCMediaPlayerStatusPlaying,       // 播放中
    YCMediaPlayerStatusStopped,       //暂停播放
    YCMediaPlayerStatusFinished       //播放完毕
};

@interface YCMediaPlayer : NSObject

@property (nonatomic, strong, readonly, nullable) AVPlayer *player;

@property (nonatomic, strong, nullable) AVPlayerItem *currentItem;

@property (nonatomic, copy) NSString *mediaURLString;

@property (nonatomic, assign) YCMediaPlayerStatus status;

- (instancetype)initWithMediaURLString:(NSString *)mediaURLString;

@end

NS_ASSUME_NONNULL_END