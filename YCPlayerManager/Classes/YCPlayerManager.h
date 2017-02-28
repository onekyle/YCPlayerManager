//
//  YCPlayerManager.h
//  Pods
//
//  Created by Durand on 27/2/17.
//
//

#import "YCMediaPlayer.h"
#import "YCPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCPlayerManager : NSObject

@property (nonatomic, strong, readonly) YCMediaPlayer *mediaPlayer;

@property (nonatomic, copy) NSString *mediaURLString;

@property (nonatomic, strong) UIView<YCPlayerViewComponentDelegate> *playerView;

@property (nonatomic, assign, readonly, getter=isSuspending) BOOL suspending;


// control
- (void)play;
- (void)stop;

- (instancetype)initWithMediaPlayer:(nullable YCMediaPlayer *)mediaPlayer playerView:(nullable UIView <YCPlayerViewComponentDelegate>*)playerView;
@end

NS_ASSUME_NONNULL_END