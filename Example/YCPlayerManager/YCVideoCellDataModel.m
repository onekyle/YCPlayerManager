//
//  YCVideoCellDataModel.m
//  YCPlayerManager
//
//  Created by Durand on 4/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCVideoCellDataModel.h"

@implementation YCVideoCoverModel

@end

@implementation YCVideoCellDataModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"cover"]) {
        self.cover = [YCVideoCoverModel modelWithDict:value];
    } else if ([key isEqualToString:@"playInfo"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            [value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull subKey, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([subKey isEqualToString:@"urlList"] && [obj isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *subDict in obj) {
                        NSString *hdURL = subDict[@"url"];
                        if (hdURL) {
                            [self.hdSources addObject:hdURL];
                        }
                    }
                }
            }];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

@end
