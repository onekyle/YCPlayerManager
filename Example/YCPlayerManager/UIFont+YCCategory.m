//
//  UIFont+YCCategory.m
//  Common
//
//  Created by Durand on 28/3/17.
//  Copyright © 2017年. All rights reserved.
//

#import "UIFont+YCCategory.h"

const CGFloat kYCFontSize1 = 20;
const CGFloat kYCFontSize2 = 18;
const CGFloat kYCFontSize3 = 16;
const CGFloat kYCFontSize4 = 14;
const CGFloat kYCFontSize5 = 12;
const CGFloat kYCFontSize6 = 10;

@implementation UIFont (YCCategory)

+ (instancetype)fontInPingFangSCLightWithFontSize:(CGFloat)fontSize
{
    return [self fontInPingFangSCWithType:UIFontPingFangSCTypeLight fontSize:fontSize];
}

+ (instancetype)fontInYCDefaultFountWithFontSize:(CGFloat)fontSize
{
    BOOL systemVersionBelow9 = [UIDevice currentDevice].systemVersion.floatValue < 9.0;
    NSString *fontName = systemVersionBelow9 ? @"STHeitiSC-Medium" : @"PingFangSC-Regular";
    return [self fontWithName:fontName size:fontSize];
}

+ (instancetype)fontInPingFangSCWithType:(UIFontPingFangSCType)type fontSize:(CGFloat)fontSize
{
    // 9之后才有的pingfangSC字体 9之前用STHeitiSC
    BOOL systemVersionBelow9 = [UIDevice currentDevice].systemVersion.floatValue < 9.0;
    NSString *fontName = nil;
    switch (type) {
        case UIFontPingFangSCTypeLight:
            fontName = systemVersionBelow9 ? @"STHeitiSC-Light" : @"PingFangSC-Light";
            break;
        case UIFontPingFangSCTypeRegular:
            fontName = systemVersionBelow9 ? @"STHeitiSC-Medium" : @"PingFangSC-Regular";
            break;
        case UIFontPingFangSCTypeMedium:
            fontName = systemVersionBelow9 ? @"STHeitiSC-Medium" : @"PingFangSC-Medium";
            break;
        default:
            break;
    }
    return [self fontWithName:fontName size:fontSize];
}

@end
