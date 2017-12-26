//
//  SJNetworkRequestManager.m
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/26.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkRequestEngine.h"
#import "SJNetworkCacheManager.h"
#import "SJNetworkRequestPool.h"
#import "SJNetworkConfig.h"
#import "SJNetworkUtils.h"
#import "SJNetworkProtocol.h"

@interface SJNetworkRequestEngine()<SJNetworkProtocol>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) SJNetworkCacheManager *cacheManager;

@end


@implementation SJNetworkRequestEngine
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
        
        //cachec manager
        _cacheManager = [SJNetworkCacheManager sharedManager];
        
        //debug mode or not
        _isDebugMode = [SJNetworkConfig sharedConfig].debugMode;
        
        //AFSessionManager config
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        //RequestSerializer
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.allowsCellularAccess = YES;
        
        _sessionManager.requestSerializer.timeoutInterval = [SJNetworkConfig sharedConfig].timeoutSeconds;
        
        //securityPolicy
        _sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        [_sessionManager.securityPolicy setAllowInvalidCertificates:YES];
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
        //ResponseSerializer
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        
        //Queue
        _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        
    }
    return self;
}


#pragma mark- ============== Public Methods ==============


- (void)sendRequest:(NSString *)url
             method:(SJRequestMethod)method
         parameters:(id)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock)successBlock
            failure:(SJFailureBlock)failureBlock{
    

    //generate complete url string
    NSString *completeUrlStr = [SJNetworkUtils generateCompleteRequestUrlStrWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                             requestUrlStr:url];
    
    
    //request method
    NSString *methodStr = [self p_methodStringFromRequestMethod:method];
    
    
    //generate a unique identifer of a certain request
    NSString *requestIdentifer = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url
                                                                              methodStr:methodStr
                                                                             parameters:parameters];
    
    
    if (loadCache) {
        
        //if client wants to load cache
        [_cacheManager loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(id  _Nullable cacheObject) {
            
            if (cacheObject) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(_isDebugMode){
                        SJLog(@"=========== Request succeed by loading Cache! \n =========== Request url:%@\n =========== Response object:%@", completeUrlStr,cacheObject);
                    }
                    
                    if (successBlock) {
                        successBlock(cacheObject);
                        return;
                    }
                });
                
                
            }else{
                
                SJLog(@"=========== Failed to load cache, start to sending network request...");
                [self p_sendRequestWithCompleteUrlStr:completeUrlStr
                                               method:methodStr
                                           parameters:parameters
                                            loadCache:loadCache
                                        cacheDuration:cacheDuration
                                     requestIdentifer:requestIdentifer
                                              success:successBlock
                                              failure:failureBlock];
                
            }
            
        }];
        
    }else {
        
        SJLog(@"=========== Do not need to load cache, start sending network request...");
        [self p_sendRequestWithCompleteUrlStr:completeUrlStr
                                       method:methodStr
                                   parameters:parameters
                                    loadCache:loadCache
                                cacheDuration:cacheDuration
                             requestIdentifer:requestIdentifer
                                      success:successBlock
                                      failure:failureBlock];
        
    }
}




#pragma mark- ============== Private Methods ==============


- (void)p_sendRequestWithCompleteUrlStr:(NSString *)completeUrlStr
                                 method:(NSString *)methodStr
                             parameters:(id)parameters
                              loadCache:(BOOL)loadCache
                          cacheDuration:(NSTimeInterval)cacheDuration
                       requestIdentifer:(NSString *)requestIdentifer
                                success:(SJSuccessBlock)successBlock
                                failure:(SJFailureBlock)failureBlock{
    
    //add customed headers
    [self addCustomHeaders];
    
    
    //add default parameters
    NSDictionary * completeParameters = [self addDefaultParametersWithCustomParameters:parameters];
    
    
    //create corresponding request model
    SJNetworkRequestModel *requestModel = [[SJNetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.method = methodStr;
    requestModel.parameters = completeParameters;
    requestModel.loadCache = loadCache;
    requestModel.cacheDuration = cacheDuration;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = successBlock;
    requestModel.failureBlock = failureBlock;
    
    
    //create a session task corresponding to a request model
    NSError * __autoreleasing requestSerializationError = nil;
    NSURLSessionDataTask *dataTask = [self p_dataTaskWithRequestModel:requestModel
                                                    requestSerializer:_sessionManager.requestSerializer
                                                                error:&requestSerializationError];
    
    
    //save task info request model
    requestModel.task = dataTask;
    
    //save this request model into request set
    [[SJNetworkRequestPool sharedPool] addRequestModel:requestModel];
    
    if (_isDebugMode) {
        SJLog(@"=========== Start requesting...\n =========== url:%@\n =========== method:%@\n =========== parameters:%@",completeUrlStr,methodStr,completeParameters);
    }
    
    
    //start request
    [dataTask resume];
    
}



- (NSURLSessionDataTask *)p_dataTaskWithRequestModel:(SJNetworkRequestModel *)requestModel
                                 requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                             error:(NSError * _Nullable __autoreleasing *)error{
    
    //create request
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestModel.method
                                                              URLString:requestModel.requestUrl
                                                             parameters:requestModel.parameters
                                                                  error:error];
    

  
    //create data task
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask * dataTask = [_sessionManager dataTaskWithRequest:request
                                                            uploadProgress:nil
                                                          downloadProgress:nil
                                                         completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error){
                                                
                                      [weakSelf p_handleRequestModel:requestModel responseObject:responseObject error:error];
                                  }];
    
    return dataTask;
    
}




- (void)p_handleRequestModel:(SJNetworkRequestModel *)requestModel
              responseObject:(id)responseObject
                       error:(NSError *)error{
    
    NSError *requestError = nil;
    BOOL requestSucceed = YES;
    
    //check request state
    if (error) {
        requestSucceed = NO;
        requestError = error;
    }
    
    if (requestSucceed) {
        
        //request succeed
        requestModel.responseObject = responseObject;
        [self requestDidSucceedWithRequestModel:requestModel];
        
    } else {
        
        //request failed
        [self requestDidFailedWithRequestModel:requestModel error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self handleRequesFinished:requestModel];
        
    });
    
}




- (NSString *)p_methodStringFromRequestMethod:(SJRequestMethod)method{
    
    switch (method) {
            
        case SJRequestMethodGET:{
            return @"GET";
        }
            break;
            
        case SJRequestMethodPOST:{
            return  @"POST";
        }
            break;
            
        case SJRequestMethodPUT:{
            return  @"PUT";
        }
            break;
            
        case SJRequestMethodDELETE:{
            return  @"DELETE";
        }
            break;
    }
}


#pragma mark- ============== Override Methods ==============


- (void)requestDidSucceedWithRequestModel:(SJNetworkRequestModel *)requestModel{
    
    //write cache
    if (requestModel.cacheDuration > 0) {
        
        requestModel.responseData = [NSJSONSerialization dataWithJSONObject:requestModel.responseObject options:NSJSONWritingPrettyPrinted error:nil];
        
        if (requestModel.responseData) {
            
            [_cacheManager writeCacheWithReqeustModel:requestModel asynchronously:YES];
            
        }else{
            SJLog(@"=========== Failded to write cache, since something was wrong when transfering response data");
        }
        
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_isDebugMode) {
            SJLog(@"=========== Request succeed! \n =========== Request url:%@\n =========== Response object:%@", requestModel.requestUrl,requestModel.responseObject);
        }
        
        if (requestModel.successBlock) {
            requestModel.successBlock(requestModel.responseObject);
        }
    });
    
}


- (void)requestDidFailedWithRequestModel:(SJNetworkRequestModel *)requestModel error:(NSError *)error{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_isDebugMode) {
            SJLog(@"=========== Request failded! \n =========== Request model:%@ \n =========== NSError object:%@ \n =========== Status code:%ld",requestModel,error,(long)error.code);
        }
        
        if (requestModel.failureBlock){
            requestModel.failureBlock(requestModel.task, error, error.code);
        }
        
    });
}




- (id)addDefaultParametersWithCustomParameters:(id)parameters{
    
    //if there is default parameters, then add them into custom parameters
    id parameters_spliced = nil;
    
    if (parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        
        if ([[[SJNetworkConfig sharedConfig].defailtParameters allKeys] count] > 0) {
            
            NSMutableDictionary *defaultParameters_m = [[SJNetworkConfig sharedConfig].defailtParameters mutableCopy];
            [defaultParameters_m addEntriesFromDictionary:parameters];
            parameters_spliced = [defaultParameters_m copy];
            
        }else{
            
            parameters_spliced = parameters;
        }
        
    }else{
        
        parameters_spliced = [SJNetworkConfig sharedConfig].defailtParameters;
        
    }
    
    return parameters_spliced;
}


- (void)addCustomHeaders{
    
    //add custom header
    NSDictionary *customHeaders = [SJNetworkConfig sharedConfig].customHeaders;
    if ([customHeaders allKeys] > 0) {
        
        NSArray *allKeys = [customHeaders allKeys];
        if ([allKeys count] >0) {
            [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
                [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
                if (_isDebugMode) {
                    SJLog(@"=========== added header:key:%@ value:%@",key,value);
                }
            }];
        }
    }
}



#pragma mark- ============== SJNetworkProtocol ==============

- (void)handleRequesFinished:(SJNetworkRequestModel *)requestModel{
    
    //clear all blocks
    [requestModel clearAllBlocks];
    
    //remove this requst model from request queue
    [[SJNetworkRequestPool sharedPool] removeRequestModel:requestModel];
    
}




@end
