//
//  YCPlayer.h
//  Pods
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "YCPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YCPlayerControlAddtion <NSObject>

- (void)pauseWithoutChangeStatus;

- (void)playWithoutChangeStatus;

@end


@interface YCPlayer : NSObject

@property (nonatomic, strong, readonly, nullable) AVPlayer<YCPlayerControlAddtion> *metaPlayer;

@property (nonatomic, strong, readonly) AVPlayerLayer *currentLayer;

@property (nonatomic, strong, nullable) AVPlayerItem *currentItem;

@property (nonatomic, copy, nullable) NSString *mediaURLString;

@property (nonatomic, assign) YCPlayerStatus status;

@property (nonatomic, weak) id<YCPlayerDelegate> playerDelegate;

/** background play related*/
@property (nonatomic, assign) BOOL hasCorrectFalg;

@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval duration;
@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval currentTime;
@property (NS_NONATOMIC_IOSONLY, getter=isPaused, readonly) BOOL paused;
@property (NS_NONATOMIC_IOSONLY, getter=isPlayable, readonly) BOOL playable;

- (instancetype)init;

- (void)startPlayingWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void(^)())completionHandler;

- (void)reset;

@end



NS_ASSUME_NONNULL_END
