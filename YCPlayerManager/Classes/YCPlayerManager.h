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

@property (nonatomic, strong, readonly) YCPlayer *player;

@property (nonatomic, copy, nullable) NSString *mediaURLString;

@property (nonatomic, strong, nullable) UIView<YCPlayerViewComponentDelegate> *playerView;

@property (nonatomic, assign, readonly, getter=isSuspending) BOOL suspending;

// background related
@property (nonatomic, assign, getter=isEnableBackgroundPlay) BOOL enableBackgroundPlay;



+ (instancetype)shareManager;

- (instancetype)initWithplayer:(nullable YCPlayer *)player playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView NS_DESIGNATED_INITIALIZER;


// control
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)targetTime;

- (BOOL)isControllable;

@property (NS_NONATOMIC_IOSONLY, getter=isPaused, readonly) BOOL paused;

@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval currentTime;

@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval duration;

- (BOOL)playerIsPlayingURLString:(NSString *)URLString;

- (void)onAudioSessionInterruptionEvent:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onAudioSessionRouteChange:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeActive:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeInactive:(NSNotification *)notification YC_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
