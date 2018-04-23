//
//  YCPlayerManager.h
//  Pods
//
//  Created by Durand on 27/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCPlayer.h"
#import "YCPlayerView.h"

#define YC_REQUIRES_SUPER __attribute__((objc_requires_super))

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const kYCPlayerStatusChangeNotificationKey;

@interface YCPlayerManager : NSObject <YCPlayerDelegate>

@property (nonatomic, strong) YCPlayer *player;

@property (nonatomic, copy, readonly, nullable) NSString *mediaURLString;

@property (nonatomic, strong, nullable) UIView<YCPlayerViewComponentDelegate> *playerView;

@property (nonatomic, assign, readonly, getter=isSuspending) BOOL suspending;

// background related
@property (nonatomic, assign, getter=isEnableBackgroundPlay) BOOL enableBackgroundPlay;

@property (NS_NONATOMIC_IOSONLY, getter=isPaused, readonly) BOOL paused;

@property (NS_NONATOMIC_IOSONLY) NSTimeInterval currentTime;

@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval duration;


+ (instancetype)shareManager;

- (instancetype)initWithplayer:(nullable YCPlayer *)player playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView NS_DESIGNATED_INITIALIZER;


/**
 播放一个URL源.
 
 @param mediaURLString URL源
 @param completionHandler 加载完成的回调.
 */
- (void)playWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void (^)(void))completionHandler;


/**
 播放一个URL源.

 @param mediaURLString URL源
 @param completionHandler 加载完成的回调.
 @param equivalentHandler 如果资源与旧资源相同的回调.
 */
- (void)playWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void (^)(void))completionHandler equivalentHandler:(nullable void (^)(void))equivalentHandler;

// control
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)targetTime;
- (void)resetPlayerLayer;

- (BOOL)isControllable;

- (BOOL)playerIsPlayingURLString:(NSString *)URLString;

- (void)onAudioSessionInterruptionEvent:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onAudioSessionRouteChange:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeActive:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeInactive:(NSNotification *)notification YC_REQUIRES_SUPER;


- (BOOL)hasPausedByManual;
@end

NS_ASSUME_NONNULL_END
