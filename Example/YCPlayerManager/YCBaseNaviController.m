//
//  YCBaseNaviController.m
//  YCPlayerManager
//
//  Created by Durand on 11/6/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCBaseNaviController.h"

@interface YCBaseNaviController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) YCBaseViewController *popToViewController;
@end

@implementation YCBaseNaviController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(yc_popGestureActivity:)];
    self.interactivePopGestureRecognizer.delegate = self;
}


#pragma mark - PopGestureDelegate

- (void)yc_popGestureActivity:(UIPanGestureRecognizer *)popGesture
{
    if (popGesture.state == UIGestureRecognizerStateEnded) {
        if (![_popToViewController isKindOfClass:[YCBaseViewController class]]) {
            return;
        }
        CGFloat offsetX = [popGesture translationInView:self.view.window].x;
        if (offsetX >= ([UIScreen mainScreen].bounds.size.width / 2)) {
            _popToViewController.appearByPopGesture = YES;
        } else {
            CGFloat velocityX = [popGesture velocityInView:self.view.window].x;
            // 虽然没有最后的触摸点滑过屏幕的一半 但是如果启示加速度很大 依然可以正常触发pop返回, 所以需要标记.
            if (velocityX >= 400) {
                _popToViewController.appearByPopGesture = YES;
            } else {
                _popToViewController.appearByPopGesture = NO;
            }
            
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        NSUInteger count = self.viewControllers.count;
        if (count < 2) {
            _popToViewController = nil;
            
        } else {
            _popToViewController = self.viewControllers[count - 1];
            if ([_popToViewController isKindOfClass:[YCBaseViewController class]]) {
                _popToViewController.appearByPopGesture = YES;
            }
        }
    }
    return YES;
}

@end
