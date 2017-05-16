//
//  YCBaseModel.m
//  YCPlayerManager
//
//  Created by Durand on 4/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCBaseModel.h"
#import <objc/runtime.h>

@implementation YCBaseModel
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

- (NSString *)description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; ++i) {
        Ivar meber = ivarList[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(meber)];
        id ivarObj = [self valueForKey:key];
        if (!ivarObj) {
            [dict setObject:@"null" forKey:key];
        } else if ([ivarObj isKindOfClass:[YCBaseModel class]]) {
            [dict setObject:[ivarObj description] forKey:key];
        } else {
            [dict setObject:ivarObj forKey:key];
        }
    }
    free(ivarList);
    return [NSString stringWithFormat:@"%@: %@",[self class], dict];
}

- (NSString *)debugDescription
{
    return [self description];
}
@end
