//
//  UIFont+YCCategory.h
//  Common
//
//  Created by Durand on 28/3/17.
//  Copyright © 2017年. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 纯白*/
#define YCFontFontColor1 [UIColor whiteColor]
/** 33*/
#define YCFontFontColor2 [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]
/** 72*/
#define YCFontFontColor3 [UIColor colorWithRed:72/255.0 green:72/255.0 blue:72/255.0 alpha:1.0]
/** 133*/
#define YCFontFontColor4 [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0]
/** 158*/
#define YCFontFontColor5 [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1.0]
/** 244*/
#define YCFontFontColor6 [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0]
/** 179*/
#define YCFontFontColor7 [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0]


#define YCFont(size) [UIFont fontInYCDefaultFountWithFontSize:size]
/** 20*/
FOUNDATION_EXTERN const CGFloat kYCFontSize1;
/** 18*/
FOUNDATION_EXTERN const CGFloat kYCFontSize2;
/** 16*/
FOUNDATION_EXTERN const CGFloat kYCFontSize3;
/** 14*/
FOUNDATION_EXTERN const CGFloat kYCFontSize4;
/** 12*/
FOUNDATION_EXTERN const CGFloat kYCFontSize5;
/** 10*/
FOUNDATION_EXTERN const CGFloat kYCFontSize6;

typedef NS_ENUM(NSUInteger, UIFontPingFangSCType) {
    UIFontPingFangSCTypeLight,
    UIFontPingFangSCTypeRegular,
    UIFontPingFangSCTypeMedium,
};

@interface UIFont (YCCategory)
+ (instancetype)fontInPingFangSCLightWithFontSize:(CGFloat)fontSize;
+ (instancetype)fontInYCDefaultFountWithFontSize:(CGFloat)fontSize;
+ (instancetype)fontInPingFangSCWithType:(UIFontPingFangSCType)type fontSize:(CGFloat)fontSize;

@end
