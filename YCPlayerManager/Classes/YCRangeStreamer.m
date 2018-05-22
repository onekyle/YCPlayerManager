//
//  YCRangeStreamer.m
//  AFNetworking
//
//  Created by Kyle on 19/5/18.
//

#import "YCRangeStreamer.h"

@implementation YCRangeStreamer


- (id)init
{
    if(!(self = [super init])) return nil;
    
    _shouldCancel = NO;
    _currentOffset = 0;
    _chunkSize = 1024 * 1024;
    _contentLength = 1;
    
    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}



- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURLRequest *request = loadingRequest.request;
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    AVAssetResourceLoadingContentInformationRequest *contentRequest = loadingRequest.contentInformationRequest;
    
    NSMutableURLRequest* mutableRequest = [request mutableCopy];
    
    NSURLComponents *commpents = [NSURLComponents componentsWithString:mutableRequest.URL.absoluteString];
    [commpents setScheme:@"http"];
    
    mutableRequest.URL = commpents.URL;
    [mutableRequest setValue:[NSString stringWithFormat:@"bytes=%lli-%lli", dataRequest.requestedOffset, dataRequest.requestedOffset + dataRequest.requestedLength - 1] forHTTPHeaderField:@"Range"];
    [[[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"find error: %@",error);
        } else {
            [dataRequest respondWithData:data];
        }
    }] resume];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadingRequest finishLoading];
    });
//    [loadingRequest finishLoading];
    
    return YES;
    
    // Add auth headers
    //    [SNDMecha configureRequest:mutableRequest action:mutableRequest.URL.path contentType:@"application/octet-stream" data:[NSData new]];
    
    while(_currentOffset < _contentLength)
    {
        
        if(_shouldCancel)
        {
            NSLog(@"Cancel Steamer");
            break;
        }
        
        if(dataRequest.requestedOffset == 0 && dataRequest.requestedLength == 2)
        {
            [mutableRequest setValue:[NSString stringWithFormat:@"bytes=%lli-%lli", dataRequest.requestedOffset, dataRequest.requestedOffset + dataRequest.requestedLength] forHTTPHeaderField:@"Range"];
        }else
        {
            [mutableRequest setValue:[NSString stringWithFormat:@"bytes=%li-%li", _currentOffset, _currentOffset + _chunkSize] forHTTPHeaderField:@"Range"];
        }
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
//        [[[NSURLSession sharedSession] dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//        }] resume];
        NSData *data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
        
        if(error)
        {
            NSLog(@"STREAM ERROR: %@", error);
            continue;
        }
        
        if(!response.allHeaderFields[@"Content-Range"])
        {
            NSLog(@"STREAM MISSING CONTENT-RANGE: %@", response);
            break;
        }
        
        if(contentRequest)
        {
            contentRequest.byteRangeAccessSupported = YES;
            contentRequest.contentType = @"public.mp3";
            contentRequest.contentLength = [[response.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"][1] integerValue];
            
            _contentLength = contentRequest.contentLength;
        }
        
        if(dataRequest.requestedOffset == 0 && dataRequest.requestedLength == 2)
        {
            break;
        }
        
        [dataRequest respondWithData:data];
        _currentOffset += data.length + 1;
    }
    
    [loadingRequest finishLoading];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    _shouldCancel = YES;
}

- (void)dealloc
{
    _shouldCancel = YES;
    NSLog(@"YCRangeStreamer dealloc");
}

@end
