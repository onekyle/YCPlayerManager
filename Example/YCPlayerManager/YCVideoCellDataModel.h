//
//  YCVideoCellDataModel.h
//  YCPlayerManager
//
//  Created by Durand on 4/5/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCBaseModel.h"

@interface YCVideoCoverModel : YCBaseModel
@property (nonatomic, copy) NSString *feed;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *blurred;
@end


@interface YCVideoCellDataModel : YCBaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) YCVideoCoverModel *cover;
@property (nonatomic, strong) NSMutableArray *hdSources;
@end
