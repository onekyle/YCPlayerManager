//
//  YCNormalCellDataModel.h
//  YCPlayerManager
//
//  Created by Durand on 2/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCNormalCellDataModel : NSObject
@property (nonatomic, copy) NSString *reuseidentity;
@property (nonatomic, strong) UIColor *iconFake;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailTitle;

+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end
