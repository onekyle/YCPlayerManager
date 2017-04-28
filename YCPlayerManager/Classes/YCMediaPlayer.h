//
//  YCMediaPlayer.h
//  Pods
//
//  Created by Durand on 24/2/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "YCMediaPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCMediaPlayer : NSObject

@property (nonatomic, strong, readonly, nullable) AVPlayer *player;

@property (nonatomic, strong, readonly) AVPlayerLayer *currentLayer;

@property (nonatomic, strong, nullable) AVPlayerItem *currentItem;

@property (nonatomic, strong, nullable) NSString *mediaURLString;

@property (nonatomic, assign) YCMediaPlayerStatus status;

@property (nonatomic, weak) id<YCMediaPlayerDelegate> playerDelegate;

/** background play related*/
@property (nonatomic, assign) BOOL hasCorrectFalg;

- (NSTimeInterval)duration;

- (instancetype)initWithMediaURLString:(NSString *)mediaURLString;

@end



NS_ASSUME_NONNULL_END
