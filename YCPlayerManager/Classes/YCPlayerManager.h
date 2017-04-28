//
//  YCPlayerManager.h
//  Pods
//
//  Created by Durand on 27/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCMediaPlayer.h"
#import "YCPlayerView.h"

#define YC_REQUIRES_SUPER __attribute__((objc_requires_super))

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const kYCPlayerStatusChangeNotificationKey;

@interface YCPlayerManager : NSObject

@property (nonatomic, strong, readonly) YCMediaPlayer *mediaPlayer;

@property (nonatomic, copy, nullable) NSString *mediaURLString;

@property (nonatomic, strong, nullable) UIView<YCPlayerViewComponentDelegate> *playerView;

@property (nonatomic, assign, readonly, getter=isSuspending) BOOL suspending;

// background related
@property (nonatomic, assign, getter=isEnableBackgroundPlay) BOOL enableBackgroundPlay;


// control
- (void)play;
- (void)pause;
- (void)stop;

- (BOOL)isPaused;

- (NSTimeInterval)currentTime;

- (NSTimeInterval)duration;

+ (instancetype)shareManager;

- (instancetype)initWithMediaPlayer:(nullable YCMediaPlayer *)mediaPlayer playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView;


- (void)onAudioSessionInterruptionEvent:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onAudioSessionRouteChange:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeActive:(NSNotification *)notification YC_REQUIRES_SUPER;

- (void)onBecomeInactive:(NSNotification *)notification YC_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
