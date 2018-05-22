//
//  YCRangeStreamer.h
//  AFNetworking
//
//  Created by Kyle on 19/5/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface YCRangeStreamer : NSObject <AVAssetResourceLoaderDelegate, NSURLSessionDelegate>
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, assign) NSInteger chunkSize;
@property (nonatomic, assign) BOOL shouldCancel;
@property (nonatomic, assign) NSInteger contentLength;
@property (nonatomic, strong) NSURLSession *session;
@end
