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

@interface YCPlayer : NSObject

@property (nonatomic, strong, readonly, nullable) AVPlayer *metaPlayer;

@property (nonatomic, strong, readonly) AVPlayerLayer *currentLayer;

@property (nonatomic, strong, nullable) AVPlayerItem *currentItem;

@property (nonatomic, copy, nullable) NSString *mediaURLString;

@property (nonatomic, assign) YCPlayerStatus status;

@property (nonatomic, weak) id<YCPlayerDelegate> playerDelegate;

/** background play related*/
@property (nonatomic, assign) BOOL hasCorrectFalg;


- (instancetype)initWithMediaURLString:(NSString *)mediaURLString NS_DESIGNATED_INITIALIZER;

- (void)startPlayingWithMediaURLString:(NSString *)mediaURLString completionHandler:(nullable void(^)())completionHandler;

@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval duration;
@property (NS_NONATOMIC_IOSONLY, readonly) NSTimeInterval currentTime;

- (BOOL)isPaused;

- (BOOL)isPlayable;
@end



NS_ASSUME_NONNULL_END
