//
//  SJNetworkDownloadManager.m
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/25.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkDownloadEngine.h"
#import "SJNetworkDownloadResumeDataInfo.h"
#import "SJNetworkCacheManager.h"
#import "SJNetworkRequestPool.h"
#import "SJNetworkConfig.h"
#import "SJNetworkUtils.h"
#import "SJNetworkProtocol.h"


@interface SJNetworkDownloadEngine()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,SJNetworkProtocol>

@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) NSURLSession *backgroundDownloadSession;

@property (nonatomic, strong) SJNetworkCacheManager *cacheManager;

@end


@implementation SJNetworkDownloadEngine
{
    NSFileManager *_fileManager;
    BOOL _isDebugMode;
}

#pragma mark- ============== Life Cycle Methods ==============


- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        //file  manager
        _fileManager = [NSFileManager defaultManager];
        
        //debug mode
        _isDebugMode = [SJNetworkConfig sharedConfig].debugMode;
        
        //cache manager
        _cacheManager = [SJNetworkCacheManager sharedManager];
    }
    
    return self;
}


- (void)dealloc{

    [_backgroundDownloadSession invalidateAndCancel];
    [_backgroundDownloadSession resetWithCompletionHandler:^{
        
    }];
    
    [_downloadSession invalidateAndCancel];
    [_downloadSession resetWithCompletionHandler:^{
        
    }];
    
}


#pragma mark- ============== Setter and Getter ==============

- (NSURLSession *)downloadSession
{
    static NSURLSession *downloadSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = [SJNetworkConfig sharedConfig].timeoutSeconds;
        downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                        delegate:self
                                                   delegateQueue:[NSOperationQueue mainQueue]];
      
 
    });
    return downloadSession;
    
}



- (NSURLSession *)backgroundDownloadSession
{
    static NSURLSession *backgroundDownloadSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"SJNetworkBackgroundSession";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        sessionConfig.timeoutIntervalForRequest = [SJNetworkConfig sharedConfig].timeoutSeconds;
        backgroundDownloadSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                  delegate:self
                                                             delegateQueue:[NSOperationQueue mainQueue]];
    });
    return backgroundDownloadSession;
    
}


#pragma mark- ============== Public Methods ==============

#pragma mark ============== Download API ==============


- (void)sendDownloadRequest:(NSString * _Nonnull)url
              ignoreBaseUrl:(BOOL)ignoreBaseUrl
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                  resumable:(BOOL)resumable
          backgroundSupport:(BOOL)backgroundSupport
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
    //complete request url
    NSString *completeUrlStr = nil;
    
    // a unique identifer of a download request
    NSString *requestIdentifer = nil;
    
    if (ignoreBaseUrl) {
        
        completeUrlStr   = url;
        requestIdentifer = [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:nil
                                                                            requestUrlStr:url];
    }else{
        
        completeUrlStr   = [[SJNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                            requestUrlStr:url];
    }
    
    //Check if a download task with same download url exists
    __block BOOL sameUrlTaskExists = NO;
    if ([[SJNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
            if ([requestModel.requestUrl isEqualToString:completeUrlStr]) {
                sameUrlTaskExists = YES;
                SJLog(@"=========== Download request can not be started, since there is a task with the same download url:%@",completeUrlStr);
                return;
            }
        }];
    }
    if (sameUrlTaskExists) {
        return;
    }
    
    NSString *downloadTargetFilePath = nil;
    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadFilePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    // If given downloadFilePath is a directory, then append it with file name to get downloadTargetFilePath(download file path)
    if (isDirectory) {
        NSString *fileName = [completeUrlStr lastPathComponent];
        downloadTargetFilePath = [NSString pathWithComponents:@[downloadFilePath, fileName]];
    } else {
        downloadTargetFilePath = downloadFilePath;
    }
    
    
    
    //remove same file in target download path
    if ([_fileManager fileExistsAtPath:downloadTargetFilePath]) {
        [_fileManager removeItemAtPath:downloadTargetFilePath error:nil];
    }
    
    
    
    
    //default method is GET
    NSString *methodStr = @"GET";
    
    //create corresponding request model and send request with it
    SJNetworkRequestModel *requestModel = [[SJNetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.downloadFilePath = downloadTargetFilePath;
    requestModel.resumableDownload = resumable;
    requestModel.backgroundDownloadSupport = backgroundSupport;
    requestModel.manualOperation = SJDownloadManualOperationStart;
    requestModel.downloadSuccessBlock = downloadSuccessBlock;
    requestModel.downloadProgressBlock = downloadProgressBlock;
    requestModel.downloadFailureBlock = downloadFailureBlock;
    
    NSURLSessionTask *downloadTask = nil;
    
    if (requestModel.backgroundDownloadSupport) {
        
        //downloadTask class : NSURLSessionDownloadTask
        downloadTask = [self p_backgroundDownloadTaskWithRequestModel:requestModel];
        
    }else{
        
        //downloadTask class : NSURLSessionDataTask
        downloadTask = [self p_noneBackgroundDownloadTaskWithRequestModel:requestModel];
    }
    
    //keep task in request model
    requestModel.task = downloadTask;
    
    //move this request model into requests set
    [[SJNetworkRequestPool sharedPool] addRequestModel:requestModel];
    
    SJLog(@"=========== start downloading:\n =========== url:%@\n =========== downloadPath:%@",completeUrlStr,requestModel.downloadFilePath);
    
    
    //start request
    [downloadTask resume];
    
    
}

#pragma mark ============== Suspend API ==============


- (void)suspendAllDownloadRequests{
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    __block BOOL hasDownloadRequests = NO;
    [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if (requestModel.requestType == SJRequestTypeDownload) {
            hasDownloadRequests = YES;
            
            if (requestModel.task) {
                
                if (requestModel.task.state == NSURLSessionTaskStateRunning) {
                    
                    if (requestModel.backgroundDownloadSupport) {
                        
                        requestModel.manualOperation = SJDownloadManualOperationSuspend;
                        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask*)requestModel.task;
                        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        }];
                        
                    }else{
                        
                        [requestModel.task suspend];
                        [_cacheManager updateResumeDataInfoAfterSuspendWithRequestModel:requestModel];
                        SJLog(@"=========== Suspended request:%@",requestModel);
                        
                    }
                    
                    
                }else {
                    SJLog(@"=========== Request %@ can not be suspended,since it is not running",requestModel);
                }
                
            }else {
                SJLog(@"=========== There is no donwload task of this request");
            }
        }
    }];
    
    if (!hasDownloadRequests) {
        SJLog(@"=========== There is no donwload task to suspend");
    }
}



- (void)suspendDownloadRequest:(NSString * _Nonnull)url;{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    //a unique identifer of a download request
    NSString *downloadRequestIdentifier =  [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                                            requestUrlStr:url];
    [self p_suspendDownloadRequestWithDownloadRequestIdentifier:downloadRequestIdentifier];
    
}


- (void)suspendDownloadRequest:(NSString * _Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    NSString *baseUrl = nil;
    
    if (!ignoreBaseUrl) {
        baseUrl = [SJNetworkConfig sharedConfig].baseUrl;
    }
    
    [self p_suspendDownloadRequestWithDownloadRequestIdentifier:[SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:baseUrl requestUrlStr:url]];
    
}


- (void)suspendDownloadRequests:(NSArray * _Nonnull)urls{
    
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== There is no input donwload urls!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendDownloadRequest:url];
    }];
}


- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== There is no input donwload urls!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendDownloadRequest:url ignoreBaseUrl:ignoreBaseUrl];
    }];
    
}


#pragma mark ============== Resume API ==============


- (void)resumeAllDownloadRequests{
    
    __block BOOL hasDownloadRequests = NO;
    
    [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        
        if (requestModel.requestType == SJRequestTypeDownload) {
            
            hasDownloadRequests = YES;
            
            if (requestModel.task) {
                
                if(requestModel.backgroundDownloadSupport){
                    
                    NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
                    
                    if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
                        if (resumeData) {
                            NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier];
                            NSURLSessionTask * downloadTask = [self.backgroundDownloadSession downloadTaskWithResumeData:resumeData];
                            requestModel.task = downloadTask;
                            //change request model
                            [[SJNetworkRequestPool sharedPool] changeRequestModel:requestModel forKey:oldTaskKey];
                            [downloadTask resume];
                            SJLog(@"=========== Resumed background support download request: %@",requestModel);
                        }else{
                            SJLog(@"=========== Can not resume background support download request: %@, since resume data is not available",requestModel);
                        }
                    }else{
                        SJLog(@"=========== Can not resume background support download request: %@, since there is no resume data in path %@",requestModel,resumeDataFilePath);
                    }
                    
                    
                }else{
                    if (requestModel.task.state == NSURLSessionTaskStateSuspended) {
                        [requestModel.task resume];
                        SJLog(@"=========== Resumed request: %@",requestModel);
                    }else{
                        SJLog(@"=========== Can not resume request: %@, since it is not suspended",requestModel);
                    }
                }
                
            }else {
                SJLog(@"=========== There is no download task of this request");
            }
        }
    }];
    
    if (!hasDownloadRequests) {
        SJLog(@"=========== There is no donwload task to resume");
    }
    
}

- (void)resumeDownloadReqeust:(NSString *_Nonnull)url{
    
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    //a unique identifer of a download request
    NSString *downloadRequestIdentifier =  [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                                            requestUrlStr:url];
    [self p_resumeDownloadRequestWithDownloadRequestIdentifier:downloadRequestIdentifier];
    
    
}

- (void)resumeDownloadReqeust:(NSString *_Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return;
    }
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    NSString *baseUrl = nil;
    
    if (!ignoreBaseUrl) {
        baseUrl = [SJNetworkConfig sharedConfig].baseUrl;
    }
    
    //a unique identifer of a download request
    NSString *downloadRequestIdentifier =  [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:baseUrl
                                                                                            requestUrlStr:url];
    [self p_resumeDownloadRequestWithDownloadRequestIdentifier:downloadRequestIdentifier];
}


- (void)resumeDownloadReqeusts:(NSArray *_Nonnull)urls{
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== There is no input donwload urls!");
        }
        return;
    }
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resumeDownloadReqeust:url];
    }];
    
}

- (void)resumeDownloadReqeusts:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== There is no input donwload urls!");
        }
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString * url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resumeDownloadReqeust:url ignoreBaseUrl:ignoreBaseUrl];
    }];
    
}




#pragma mark ============== Cancel API ==============


- (void)cancelAllDownloadRequests{
    
    if(![[SJNetworkRequestPool sharedPool] remainingCurrentRequests]){
        return;
    }
    
    __block BOOL hasDownloadRequests = NO;
    [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if (requestModel.requestType == SJRequestTypeDownload) {
            
            hasDownloadRequests = YES;
            if (requestModel.task) {
                
                if (requestModel.backgroundDownloadSupport) {
                    
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask*)requestModel.task;
                    requestModel.manualOperation = SJDownloadManualOperationCancel;
                    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    }];
                    
                }else{
                    [requestModel.task cancel];
                }
                SJLog(@"=========== Canceled request:%@",requestModel);
            }else {
                SJLog(@"=========== There is no donwload task of this request");
            }
        }
    }];
    
    if (!hasDownloadRequests) {
        SJLog(@"=========== There is no donwload task to cancel");
    }
}




- (void)cancelDownloadRequest:(NSString * _Nonnull)url{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return;
    }
    
    [[SJNetworkRequestPool sharedPool] cancelCurrentRequestWithUrl:url];
}


- (void)cancelDownloadRequest:(NSString * _Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
         return;
    }
    
    
    NSString *requestUrl = nil;
    if (!ignoreBaseUrl) {
        requestUrl = [[SJNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
    }else{
        requestUrl = url;
    }
    
    [[SJNetworkRequestPool sharedPool] cancelCurrentRequestWithUrl:requestUrl];
    
    
}


- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls{
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url array is empty!");
        }
         return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SJNetworkRequestPool sharedPool] cancelCurrentRequestWithUrl:url];
    }];
    
}




- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if ([urls count] == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url array is empty!");
        }
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString *url, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *requestUrl = nil;
        if (!ignoreBaseUrl) {
            requestUrl = [[SJNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        }else{
            requestUrl = url;
        }
        [[SJNetworkRequestPool sharedPool] cancelCurrentRequestWithUrl:requestUrl];
    }];
}






- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return 0.0;
    }
    
    //a unique identifer of a download request
    NSString *downloadRequestIdentifier =  [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                                            requestUrlStr:url];
    
    return [self p_resumeDataRatioWithRequestIdentifier:downloadRequestIdentifier];
    
}




- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    if (url.length == 0) {
        if (_isDebugMode) {
            SJLog(@"=========== The input url is an empty string!");
        }
        return 0.0;
    }
    
    NSString *baseUrl = nil;
    
    if (!ignoreBaseUrl) {
        baseUrl = [SJNetworkConfig sharedConfig].baseUrl;
    }
    
    //a unique identifer of a download request
    NSString *downloadRequestIdentifier =  [SJNetworkUtils generateDownloadRequestIdentiferWithBaseUrlStr:baseUrl requestUrlStr:url];
    
    return [self p_resumeDataRatioWithRequestIdentifier:downloadRequestIdentifier];
    
}


#pragma mark- ============== Private Methods ==============


- (NSURLSessionTask *)p_backgroundDownloadTaskWithRequestModel:(SJNetworkRequestModel *)requestModel{
    
    
    //init download request with request url
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestModel.requestUrl]];
    
    //add custom header
    [self p_addRequestHeaderInRequest:downloadRequest];
   
    
    //temp download file
    NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
    
    NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
    
    
    if (![_fileManager fileExistsAtPath:resumeDataInfoFilePath]) {
        SJNetworkDownloadResumeDataInfo  *dataInfo = [[SJNetworkDownloadResumeDataInfo alloc] init];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
    }
    
    NSURLSessionDownloadTask *downloadTask = nil;
    
    
    if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
        
        
        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
        
        if (resumeData) {
            
            if (requestModel.resumableDownload) {
                downloadTask = [self.backgroundDownloadSession downloadTaskWithResumeData:resumeData];
                
            }else{
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
                downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
            }
            
        }else{
            
            [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
        }
        
    }else{
        
        downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
    }
    
    
    
    return downloadTask;
}



- (NSURLSessionTask *)p_noneBackgroundDownloadTaskWithRequestModel:(SJNetworkRequestModel *)requestModel{
    
    //init download request with request url
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestModel.requestUrl]];
    
    //add custom header
    [self p_addRequestHeaderInRequest:downloadRequest];
    
    
    //temp download file
    NSString *resumDataFilePath = requestModel.resumeDataFilePath;
    
    NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
    
    
    //create steam
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:resumDataFilePath append:YES];
    requestModel.stream = stream;
    
    if (requestModel.resumableDownload) {
        
        if ([_fileManager fileExistsAtPath:resumeDataInfoFilePath] ) {
            
            //load resume data info
            SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
            
            //check if resume data info exsists
            if (dataInfo) {
                
                NSInteger resumeDataLength = [dataInfo.resumeDataLength integerValue];
                if (resumeDataLength > 0) {
                    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", resumeDataLength];
                    [downloadRequest setValue:range forHTTPHeaderField:@"Range"];
                }
                
            }else{
                
                //if resume data info was not available and the corresponding data exists, then delete the corresponding data
                if ([_fileManager fileExistsAtPath:resumDataFilePath]) {
                    [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
                }
                
            }
        }else {
            
            //if this is a not a resumable download request and there is no resume data info, then create one
            SJNetworkDownloadResumeDataInfo  *dataInfo = [[SJNetworkDownloadResumeDataInfo alloc] init];
            [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
            
            
        }
    }
    
    NSURLSessionDataTask *downloadTask = [self.downloadSession dataTaskWithRequest:downloadRequest];
    return downloadTask;
    
}


- (void)p_addRequestHeaderInRequest:(NSMutableURLRequest *)request{
    
    NSDictionary *customHeaders = [SJNetworkConfig sharedConfig].customHeaders;
    if ([customHeaders allKeys] > 0) {
        NSArray *allKeys = [customHeaders allKeys];
        if ([allKeys count] >0) {
            [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
                [request setValue:value forHTTPHeaderField:key];
                if (_isDebugMode) {
                    SJLog(@"=========== added header:key:%@ value:%@",key,value);
                }
            }];
        }
    }
}


- (void)p_suspendDownloadRequestWithDownloadRequestIdentifier:(NSString *)downloadRequestIdentifier{
    
    [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if ([requestModel.requestIdentifer isEqualToString:downloadRequestIdentifier]) {
            
            if (requestModel.task) {
                
                if (requestModel.task.state == NSURLSessionTaskStateRunning) {
                    
                    if (requestModel.backgroundDownloadSupport) {
                        
                        requestModel.manualOperation = SJDownloadManualOperationSuspend;
                        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask*)requestModel.task;
                        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        }];
                        
                    }else{
                        
                        [requestModel.task suspend];
                        [_cacheManager updateResumeDataInfoAfterSuspendWithRequestModel:requestModel];
                        SJLog(@"=========== Suspended request:%@",requestModel);
                        
                    }
                    
                }else {
                    SJLog(@"=========== Request %@ can not be suspended,since it is not running",requestModel);
                }
                
            }else {
                SJLog(@"=========== There is no donwload task of this request");
            }
        }
    }];
    
}

- (void)p_resumeDownloadRequestWithDownloadRequestIdentifier:(NSString *)downloadRequestIdentifier{
    
    [[SJNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SJNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        
        if ([requestModel.requestIdentifer isEqualToString:downloadRequestIdentifier]) {
            
            if (requestModel.task) {
                
                if (requestModel.backgroundDownloadSupport) {
                    
                    if (requestModel.manualOperation == SJDownloadManualOperationSuspend) {
                        
                        NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
                        
                        if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                            
                            NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
                            if (resumeData) {
                                
                                NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier];
                                NSURLSessionTask * downloadTask = [self.backgroundDownloadSession downloadTaskWithResumeData:resumeData];
                                requestModel.manualOperation = SJDownloadManualOperationResume;
                                requestModel.task = downloadTask;
                                [[SJNetworkRequestPool sharedPool] changeRequestModel:requestModel forKey:oldTaskKey];
                                [downloadTask resume];
                                SJLog(@"=========== Resumed background support download request: %@",requestModel);
                                
                            }else{
                                
                                SJLog(@"=========== Can not resume background support download request: %@, since resume data is not available",requestModel);
                                
                            }
                            
                        }else{
                            
                            SJLog(@"=========== Can not resume background support download request: %@, since there is no resume data in path %@",requestModel,resumeDataFilePath);
                        }
                        
                        
                    }else{
                        
                        SJLog(@"=========== Can not resume background support download request: %@, since it is not suspended(canceled) by user",requestModel);
                    }
                    
                }else{
                    
                    if (requestModel.task.state == NSURLSessionTaskStateSuspended) {
                        [requestModel.task resume];
                        SJLog(@"=========== Resumed request: %@",requestModel);
                        
                    }else{
                        
                        SJLog(@"=========== Can not resume request: %@, since it is not suspended",requestModel);
                    }
                }
                
            }else {
                SJLog(@"=========== There is no download task of this request");
            }
        }
    }];
    
}

- (CGFloat)p_resumeDataRatioWithRequestIdentifier:(NSString *)requestIdentifier{
    
    NSString *resumeDataInfoFilePath = [SJNetworkUtils resumeDataInfoFilePathWithRequestIdentifer:requestIdentifier];
    SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
    
    if (dataInfo) {
        return [dataInfo.resumeDataRatio floatValue];
    }else{
        return 0.00;
    }
}


#pragma mark- ============== SJNetworkProtocol ==============

- (void)handleRequesFinished:(SJNetworkRequestModel *)requestModel{
    
    //clear all blocks
    [requestModel clearAllBlocks];
    
    //remove this requst model from request queue
    [[SJNetworkRequestPool sharedPool] removeRequestModel:requestModel];
    
}


#pragma mark - ============== NSURLSessionTaskDelegate ==============

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{

    if (_isDebugMode) {
        SJLog(@"=========== Download request did complete of task:%@",task);
    }

    SJNetworkRequestModel * requestModel = [[SJNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)task.taskIdentifier]];

    if (requestModel) {
        
        if (requestModel.backgroundDownloadSupport) {
            
            if (error) {
                
                //cancel request
                if (error.code == -999) {
                    
                    [requestModel.task suspend];
                    
                    NSData *resumeData = requestModel.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
                    NSError *moveDownloadFileError = nil;
                    
                    if (requestModel.resumableDownload) {
                        
                        [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:&moveDownloadFileError];
                        
                    }else{
                        
                        if (requestModel.manualOperation == SJDownloadManualOperationSuspend){
                            
                             [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:&moveDownloadFileError];
                            
                        }else{
                            
                            if (_isDebugMode) {
                                SJLog(@"=========== Because this is not resumable downloading:\n remove resume data in path:%@ \n and resume data info in path:%@",requestModel.resumeDataFilePath,requestModel.resumeDataInfoFilePath);
                            }
                            
                            [_cacheManager removeResumeDataAndResumeDataInfoFileWithRequestModel:requestModel];
                            
                        }
                        
                       
                        
                    }
                    
                    if (requestModel.manualOperation == SJDownloadManualOperationSuspend) {
                        
                        SJLog(@"=========== Suspended background support download request:%@",requestModel);
                        
                    }else{
                        
                        SJLog(@"=========== Canceled background support download request:%@",requestModel);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestModel.downloadFailureBlock) {
                                    requestModel.downloadFailureBlock(requestModel.task, error,requestModel.resumeDataFilePath);
                                
                            }
                            [self handleRequesFinished:requestModel];
                       });
                        
                    }
                    
                    
                }else{
                    
                    
                    
                    SJLog(@"=========== Background support download failed, download file path:%@",requestModel.downloadFilePath);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (requestModel.downloadFailureBlock) {
                                requestModel.downloadFailureBlock(requestModel.task, error,requestModel.resumeDataFilePath);
                        }                        
                        [self handleRequesFinished:requestModel];
                    });
                }
                
                
            }else{
                
                
                SJLog(@"=========== Download succeed,download file path:%@",requestModel.downloadFilePath);
                 dispatch_async(dispatch_get_main_queue(), ^{\
                     
                    if (requestModel.downloadSuccessBlock) {
                        requestModel.downloadSuccessBlock(requestModel.downloadFilePath);
                    }
                    [self handleRequesFinished:requestModel];
                     
                });
            }
            
            
        }else {
            
            
            if (error) {
                
                if (error.code == -997) {
                    
                    // The eror code equals to -997 means this app enters into background and then lost connect.
                    // We offer an 'auto start request mechanism' to cope with this situation
                   
                    SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
                    NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
                    NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
                    dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",(long)resumeDataLength];
                    
                    //ratio
                    CGFloat ratio = 1.0 * ([dataInfo.resumeDataLength integerValue])/([dataInfo.totalDataLength integerValue]);
                    dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
                    [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
                    
                    
                    [requestModel.stream close];
                     requestModel.stream = nil;
                    
                    //lost connection background and the task is canceled
                    NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier];
                    //init download request with request url
                    NSURLSessionTask * downloadTask = [self p_noneBackgroundDownloadTaskWithRequestModel:requestModel];
                    requestModel.task = downloadTask;
                    //change request model
                    [[SJNetworkRequestPool sharedPool] changeRequestModel:requestModel forKey:oldTaskKey];
                    [requestModel.task resume];
                    
                    
                    
                }else{
                    
                    if (requestModel.resumableDownload) {
                        
                        SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
                        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
                        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
                        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",(long)resumeDataLength];

                        //ratio
                        CGFloat ratio = 1.0 * ([dataInfo.resumeDataLength integerValue])/([dataInfo.totalDataLength integerValue]);
                        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
                        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
                        
                        
                        if (_isDebugMode) {
                            SJLog(@"=========== Keep resume data in path:%@ \n and save resume data info in path:%@, since this is a resumable donwloading",requestModel.resumeDataFilePath,requestModel.resumeDataInfoFilePath);
                        }
                        
                    }else {
                        
                        if (_isDebugMode) {
                            SJLog(@"=========== Remove resume data in path:%@ \n and resume data info in path:%@, since this is not a resumable donwloading",requestModel.resumeDataFilePath,requestModel.resumeDataInfoFilePath);
                        }
                        
                        [_cacheManager removeResumeDataAndResumeDataInfoFileWithRequestModel:requestModel];
                        
                    }
                    
                    
                    [requestModel.stream close];
                     requestModel.stream = nil;
                    
                    
                    SJLog(@"=========== Download failed,download file path:%@",requestModel.downloadFilePath);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (requestModel.downloadFailureBlock) {
                                requestModel.downloadFailureBlock(requestModel.task, error,requestModel.resumeDataFilePath);
                        }
                        [self handleRequesFinished:requestModel];
                    });
                    
                }
                
            }else {
                
                //download succeed
                [_cacheManager removeCompleteDownloadDataAndClearResumeDataInfoFileWithRequestModel:requestModel];
                
                [requestModel.stream close];
                 requestModel.stream = nil;
                
                SJLog(@"=========== Download succeed,download file path:%@",requestModel.downloadFilePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (requestModel.downloadSuccessBlock) {
                        requestModel.downloadSuccessBlock(requestModel.downloadFilePath);
                    }
                    [self handleRequesFinished:requestModel];
                });
            }
        }
    }
}



- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{

    if (_isDebugMode) {
        SJLog(@"=========== Did received response:%@ \n of task:%@",response,dataTask);
    }

    SJNetworkRequestModel * requestModel = [[SJNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)dataTask.taskIdentifier]];

    if (requestModel) {
        
        
        
        NSInteger statusCode  = 0;
        if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse*)dataTask.response statusCode];
        }
        
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        NSString *resumeDataFilePath= requestModel.resumeDataFilePath;
        
        if (statusCode > 400) {
            
            NSError *error = [NSError errorWithDomain:@"request error" code:statusCode userInfo:nil];
            
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            
            
            SJLog(@"=========== Download failed,download file path:%@",requestModel.downloadFilePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (requestModel.downloadFailureBlock) {
                    requestModel.downloadFailureBlock(requestModel.task, error,nil);
                }
                [self handleRequesFinished:requestModel];
            });
            
            return;
            
        }
        
        //no error, open stream
        [requestModel.stream open];

        //load resume data info
        SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
        if (!dataInfo) {
            dataInfo = [[SJNetworkDownloadResumeDataInfo alloc] init];
        }

        //resume data file length
        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:resumeDataFilePath error:nil];
        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",(long)resumeDataLength];

        //total data file length
        NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + [dataInfo.resumeDataLength integerValue];
        dataInfo.totalDataLength = [NSString stringWithFormat:@"%ld",(long)totalLength];
        requestModel.totalLength = totalLength;

        //ratio
        CGFloat ratio = 1.0 * ([dataInfo.resumeDataLength integerValue])/([dataInfo.totalDataLength integerValue]);
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];

        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];

        completionHandler(NSURLSessionResponseAllow);

    }
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{

    SJNetworkRequestModel * requestModel = [[SJNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)dataTask.taskIdentifier]];

    if (requestModel) {

        //write data in stream
        [requestModel.stream write:data.bytes maxLength:data.length];

        //update resume data info
        SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo: requestModel.resumeDataInfoFilePath];
        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",(long)resumeDataLength];
        
        CGFloat ratio = 1.0 * ([dataInfo.resumeDataLength integerValue])/([dataInfo.totalDataLength integerValue]);
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];

        if (_isDebugMode) {
            SJLog(@"=========== Download progress:%@ of task:%@",dataInfo.resumeDataRatio,requestModel.task);
        }
        if (requestModel.downloadProgressBlock) {
            requestModel.downloadProgressBlock([dataInfo.resumeDataLength integerValue] ,requestModel.totalLength,ratio);
        }

    }
}


#pragma mark - ==============  NSURLSessionDownloadDelegate ==============




- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    
    SJNetworkRequestModel * requestModel = [[SJNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)downloadTask.taskIdentifier]];
    
    
    if (requestModel) {
        
        
        NSInteger statusCode  = 0;
        if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse*)downloadTask.response statusCode];
        }
                
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        NSString *resumeDataFilePath= requestModel.resumeDataFilePath;
        
        if (statusCode > 400) {
            
            NSError *error = nil;
            if (statusCode == 416) {
                error = [NSError errorWithDomain:@"range error" code:statusCode userInfo:nil];
            }
            
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            
            
            SJLog(@"=========== Download failed,download file path:%@",requestModel.downloadFilePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (requestModel.downloadFailureBlock) {
                    requestModel.downloadFailureBlock(requestModel.task, error,nil);
                }
                [self handleRequesFinished:requestModel];
            });
            
        }else{
        
                
            NSData *tmpDownloadFileData = [NSData dataWithContentsOfURL:location];
            NSUInteger downloadDataLength = tmpDownloadFileData.length;
        
        
            //download succeed
            NSError *moveDownloadFileError = nil;
            
            //move temp download data to target file path
            [_fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:requestModel.downloadFilePath] error:&moveDownloadFileError];
            
            //remove data info file path
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            
            if (moveDownloadFileError &&  moveDownloadFileError.code != 516) {
                
                SJLog(@"=========== Download failed,download file path:%@",requestModel.downloadFilePath);
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                    if (requestModel.downloadFailureBlock) {
                            requestModel.downloadFailureBlock(requestModel.task, moveDownloadFileError,nil);
                    }
                     
                    [self handleRequesFinished:requestModel];
                 });
                
            }else {
                
                if (requestModel.downloadProgressBlock) {
                    requestModel.downloadProgressBlock(downloadDataLength, downloadDataLength, 1);
                }
                
                if (moveDownloadFileError.code == 516) {
                    [_fileManager removeItemAtPath:location.absoluteString error:nil];
                }
                
                //succeed block
                SJLog(@"=========== Download succeed,download file path:%@",requestModel.downloadFilePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (requestModel.downloadSuccessBlock) {
                        requestModel.downloadSuccessBlock(requestModel.downloadFilePath);
                    }
                    [self handleRequesFinished:requestModel];
                });
            }
            }
        }
}



- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    SJNetworkRequestModel * requestModel = [[SJNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",(unsigned long)downloadTask.taskIdentifier]];
    
    if (requestModel) {
        
        if (!requestModel.totalLength) {
             requestModel.totalLength = (NSInteger)totalBytesExpectedToWrite;
        }
        
        CGFloat ratio = 1.0 *totalBytesWritten/requestModel.totalLength;
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        SJNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
        
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%lld",totalBytesWritten];
        dataInfo.totalDataLength = [NSString stringWithFormat:@"%ld",(long)requestModel.totalLength];
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];

        [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
        
        if (_isDebugMode) {
            SJLog(@"=========== Download progress:%@ of task:%@",dataInfo.resumeDataRatio,requestModel.task);
        }
        if (requestModel.downloadProgressBlock) {
            requestModel.downloadProgressBlock((NSInteger)bytesWritten ,requestModel.totalLength,ratio);
        }
    }
    
    
}



@end
