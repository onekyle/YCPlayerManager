//
//  YCNormalCellDataModel.m
//  YCPlayerManager
//
//  Created by Durand on 2/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCNormalCellDataModel.h"

@implementation YCNormalCellDataModel
+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    id instance = [[self alloc] init];
    if (instance) {
        [instance setValuesForKeysWithDictionary:dict];
    }
    return instance;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%s: find undefined key: %@ for value: %@",__func__,key,value);
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.iconImage = [self createImageWithColor:[UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0]];
//    }
//    return self;
//}
//
//
//
//- (UIImage*)createImageWithColor: (UIColor*) color
//{
//    CGRect rect=CGRectMake(0,0, 1, 1);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return theImage;
//}


@end
