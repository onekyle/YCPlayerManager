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


@end
