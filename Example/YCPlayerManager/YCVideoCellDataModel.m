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

@implementation YCVideoProviderModel
@end

@implementation YCVideoCellDataModel

+ (NSDictionary *)dictionaryForReflect
{
    return @{@"cover": @"YCVideoCoverModel", @"provider": @"YCVideoProviderModel"};
}

+ (NSDictionary *)dictionaryForExchange
{
    return @{@"description": @"detail"};
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    NSDictionary *excDict = [[self class] dictionaryForExchange];
    if (excDict.count == 0 || keyedValues.count == 0) {
        return [super setValuesForKeysWithDictionary:keyedValues];
    }
    
    NSMutableDictionary <NSString *,id> *keyedValuesM = keyedValues.mutableCopy;
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *excKey = excDict[key];
        if (excKey) {
            keyedValuesM[excKey] = obj;
            keyedValuesM[key] = nil;
        }
    }];
    return [super setValuesForKeysWithDictionary:keyedValuesM];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    struct label *defaultImp; // 只是为了提示
#pragma clang diagnostic pop
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *reflectDict = [[self class] dictionaryForReflect];
        NSString *reflectKey = reflectDict[key];
        if (!reflectKey) {
            goto defaultImp;
        } else {
            Class SubModelClass = NSClassFromString(reflectKey);
            if (![SubModelClass conformsToProtocol:@protocol(YCBaseModelProtocol)]) {
                goto defaultImp;
            } else {
                id model = [((id <YCBaseModelProtocol>)SubModelClass) modelWithDict:value];
                return [super setValue:model forKey:key];
            }
        }
    }
    
    defaultImp : {
        [super setValue:value forKey:key];
    }
    
}

/*
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
*/
@end
