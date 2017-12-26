//
//  SJNetworkRequestPool.m
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/25.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkRequestPool.h"
#import "SJNetworkUtils.h"
#import "SJNetworkConfig.h"
#import "SJNetworkRequestModel.h"
#import "SJNetworkProtocol.h"

#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>
#import <pthread/pthread.h>


#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

static char currentRequestModelsKey;

@interface SJNetworkRequestModel()<SJNetworkProtocol>

@end

@implementation SJNetworkRequestPool
{
    pthread_mutex_t _lock;
    BOOL _isDebugMode;
}


#pragma mark- ============== Life Cycle ==============

+ (SJNetworkRequestPool *)sharedPool {
    
    static SJNetworkRequestPool *sharedPool = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedPool = [[SJNetworkRequestPool alloc] init];
    });
    return sharedPool;
}



- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        //lock
        pthread_mutex_init(&_lock, NULL);
        
        //debug mode or not
        _isDebugMode = [SJNetworkConfig sharedConfig].debugMode;
        
    }
    return self;
}

#pragma mark- ============== Public Methods ==============

- (SJCurrentRequestModels *)currentRequestModels {
    
    SJCurrentRequestModels *currentTasks = objc_getAssociatedObject(self, &currentRequestModelsKey);
    if (currentTasks) {
        return currentTasks;
    }
    currentTasks = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &currentRequestModelsKey, currentTasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return currentTasks;
}



- (void)addRequestModel:(SJNetworkRequestModel *)requestModel{
    
    Lock();
    [self.currentRequestModels setObject:requestModel forKey:[NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier]];
    Unlock();
}



- (void)removeRequestModel:(SJNetworkRequestModel *)requestModel{
    
    Lock();
    [self.currentRequestModels removeObjectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier]];
    Unlock();
    
}



- (void)changeRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel forKey:(NSString *_Nonnull)key{
    
    Lock();
    [self.currentRequestModels removeObjectForKey:key];
    [self.currentRequestModels setObject:requestModel forKey:[NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier]];
    Unlock();
    
}



- (BOOL)remainingCurrentRequests{
    
    NSArray *keys = [self.currentRequestModels  allKeys];
    if ([keys count]>0) {
        SJLog(@"=========== There is remaining current request");
        return YES;
    }
    SJLog(@"=========== There is no remaining current request");
    return NO;
}




- (NSInteger)currentRequestCount{
    
    if(![self remainingCurrentRequests]){
        return 0;
    }
    
    NSArray *keys = [self.currentRequestModels allKeys];
    SJLog(@"=========== There is %ld current requests",(unsigned long)keys.count);
    return [keys count];
    
}





- (void)logAllCurrentRequests{
    
    if ([self remainingCurrentRequests]) {
        
        [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
            SJLog(@"=========== Log current request:\n %@",requestModel);
        }];
        
    }
}





- (void)cancelAllCurrentRequests{
    
    if ([self remainingCurrentRequests]) {
        
        for (SJNetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
            
        
            if (requestModel.requestType == SJRequestTypeDownload) {
                
                if (requestModel.backgroundDownloadSupport) {
                    
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask*)requestModel.task;
                    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    }];
                    
                }else{
                    
                    [requestModel.task cancel];
                }
                
            }else{
                
                [requestModel.task cancel];
                [self removeRequestModel:requestModel];
            }
        }
        SJLog(@"=========== Canceled call current requests");
    }
    
    
}





- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url{
    
    if(![self remainingCurrentRequests]){
        return;
    }
    
    NSMutableArray *cancelRequestModelsArr = [NSMutableArray arrayWithCapacity:2];
    NSString *requestIdentiferOfUrl =  [SJNetworkUtils generateMD5StringFromString: [NSString stringWithFormat:@"Url:%@",url]];
    
    [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if ([requestModel.requestIdentifer containsString:requestIdentiferOfUrl]) {
            [cancelRequestModelsArr addObject:requestModel];
        }
    }];
    
    if ([cancelRequestModelsArr count] == 0) {
        
        SJLog(@"=========== There is no request to be canceled");
        
    }else {
        
        if (_isDebugMode) {
            SJLog(@"=========== Requests to be canceled:");
            [cancelRequestModelsArr enumerateObjectsUsingBlock:^(SJNetworkRequestModel *requestModel, NSUInteger idx, BOOL * _Nonnull stop) {
                SJLog(@"=========== cancel request with url[%ld]:%@",(unsigned long)idx,requestModel.requestUrl);
            }];
        }
        
        [cancelRequestModelsArr enumerateObjectsUsingBlock:^(SJNetworkRequestModel *requestModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            
            if (requestModel.requestType == SJRequestTypeDownload) {
                
                if (requestModel.backgroundDownloadSupport) {
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask*)requestModel.task;
                    
                    if (requestModel.task.state == NSURLSessionTaskStateCompleted) {
                        
                        SJLog(@"=========== Canceled background support download request:%@",requestModel);
                        NSError *error = [NSError errorWithDomain:@"Request has been canceled" code:0 userInfo:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (requestModel.downloadFailureBlock) {
                                requestModel.downloadFailureBlock(requestModel.task, error,requestModel.resumeDataFilePath);
                            }
                            [self handleRequesFinished:requestModel];
                        });
                        
                    }else{
                        
                        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                            
                        }];
                        SJLog(@"=========== Background support download request %@ has been canceled",requestModel);
                    }
                    
                }else{
                    
                    [requestModel.task cancel];
                    SJLog(@"=========== Request %@ has been canceled",requestModel);
                }
                
            }else{
                
                [requestModel.task cancel];
                SJLog(@"=========== Request %@ has been canceled",requestModel);
                if (requestModel.requestType != SJRequestTypeDownload) {
                    [self removeRequestModel:requestModel];
                }
            }
        }];
        
        SJLog(@"=========== All requests with request url : '%@' are canceled",url);
    }
    
    
}




- (void)cancelCurrentRequestWithUrls:(NSArray * _Nonnull)urls{
    
    if ([urls count] == 0) {
        SJLog(@"=========== There is no input urls!");
        return;
    }
    
    if(![self remainingCurrentRequests]){
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelCurrentRequestWithUrl:url];
    }];
}






- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url
                             method:(NSString * _Nonnull)method
                         parameters:(id _Nullable)parameter{
    
    if(![self remainingCurrentRequests]){
        return;
    }
    
    NSString *requestIdentifier = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                           requestUrlStr:url
                                                                               methodStr:method
                                                                              parameters:parameter];
    
    [self p_cancelRequestWithRequestIdentifier:requestIdentifier];
}



#pragma mark- ============== Private Methods ==============

- (void)p_cancelRequestWithRequestIdentifier:(NSString *)requestIdentifier{
    
    [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if ([requestModel.requestIdentifer isEqualToString:requestIdentifier]) {
            
            if (requestModel.task) {
                
                [requestModel.task cancel];
                SJLog(@"=========== Canceled request:%@",requestModel);
                if (requestModel.requestType != SJRequestTypeDownload) {
                    [self removeRequestModel:requestModel];
                }
                
            }else {
                SJLog(@"=========== There is no task of this request");
            }
        }
    }];
}




#pragma mark- ============== SJNetworkProtocol ==============

- (void)handleRequesFinished:(SJNetworkRequestModel *)requestModel{
    
    //clear all blocks
    [requestModel clearAllBlocks];
    
    //remove this requst model from request queue
    [[SJNetworkRequestPool sharedPool] removeRequestModel:requestModel];
    
}





@end
