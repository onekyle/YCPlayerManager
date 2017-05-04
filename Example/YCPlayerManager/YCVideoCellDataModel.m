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
    if ([key isEqualToString:@"description"]) {
        [super setValue:value forKey:@"detail"];
    } else if ([key isEqualToString:@"cover"]) {
        self.cover = [YCVideoCoverModel modelWithDict:value];
    } else if ([key isEqualToString:@"playInfo"]) {
        if (![value isKindOfClass:[NSArray class]]) {
            return;
        }
        NSMutableArray *sdSources = [NSMutableArray array];
        NSMutableArray *hdSources = [NSMutableArray array];
        [value enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray *urlList = obj[@"urlList"];
                if (urlList && [urlList isKindOfClass:[NSArray class]]) {
                    NSString * type = obj[@"type"];
                    // unknow: 0
                    // normal: 1
                    // high: 2
                    NSInteger typeStyle = [type isEqualToString:@"high"] ? 2 : [type isEqualToString:@"normal"] ? 1 : 0;
                    for (NSDictionary *subDict in urlList) {
                        NSString *sourceUrl = subDict[@"url"];
                        if (sourceUrl) {
                            if (typeStyle == 2) {
                                [hdSources addObject:sourceUrl];
                            } else if (typeStyle == 1) {
                                [sdSources addObject:sourceUrl];
                            }
                        }
                    }
                }
            }
        }];
        if (sdSources.count) {
            self.sdSources = sdSources;
        }
        if (hdSources.count) {
            self.hdSources = hdSources;
        }
    } else {
        [super setValue:value forKey:key];
    }
}

@end
