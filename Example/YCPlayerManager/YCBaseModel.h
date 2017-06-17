//
//  YCBaseModel.h
//  YCPlayerManager
//
//  Created by Durand on 4/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YCBaseModelProtocol <NSObject>

@required
+ (instancetype)modelWithDict:(NSDictionary *)dict;

@optional
+ (NSDictionary *)dictionaryForReflect;

+ (NSDictionary *)dictionaryForExchange;

@end

@interface YCBaseModel : NSObject <YCBaseModelProtocol>

@end
