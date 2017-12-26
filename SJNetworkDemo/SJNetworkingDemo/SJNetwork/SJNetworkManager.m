//
//  SJNetworkManager.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkManager.h"

#import "SJNetworkConfig.h"
#import "SJNetworkRequestPool.h"

#import "SJNetworkRequestEngine.h"
#import "SJNetworkUploadEngine.h"
#import "SJNetworkDownloadEngine.h"

@interface SJNetworkManager()

@property (nonatomic, strong) SJNetworkRequestEngine *requestEngine;
@property (nonatomic, strong) SJNetworkUploadEngine *uploadEngine;
@property (nonatomic, strong) SJNetworkDownloadEngine *downloadEngine;

@property (nonatomic, strong) SJNetworkRequestPool *requestPool;
@property (nonatomic, strong) SJNetworkCacheManager *cacheManager;

@end


@implementation SJNetworkManager


#pragma mark- ============== Life Cycle ===========

+ (SJNetworkManager *_Nullable)sharedManager {
    
    static SJNetworkManager *sharedManager = NULL;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
         sharedManager = [[SJNetworkManager alloc] init];
    });
    return sharedManager;
}


- (void)dealloc{
    
    [self cancelAllCurrentRequests];
}

#pragma mark- ============== Public Methods ==============


- (void)addCustomHeader:(NSDictionary *_Nonnull)header{
    
    [[SJNetworkConfig sharedConfig] addCustomHeader:header];
}




- (NSDictionary *_Nullable)customHeaders{
    
    return [SJNetworkConfig sharedConfig].customHeaders;
}


#pragma mark- ============== Request API using GET method ==============


- (void)sendGetRequest:(NSString * _Nonnull)url
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodGET
                          parameters:nil
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
    
}





- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodGET
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodGET
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}





- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{

     [self.requestEngine sendRequest:url
                              method:SJRequestMethodGET
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}





- (void)sendGetRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodGET
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}



#pragma mark- ============== Request API using POST method ==============

- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nullable)parameters
                success:(SJSuccessBlock _Nullable)successBlock
                failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPOST
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nullable)parameters
              loadCache:(BOOL)loadCache
                success:(SJSuccessBlock _Nullable)successBlock
                failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPOST
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}



- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nullable)parameters
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(SJSuccessBlock _Nullable)successBlock
                failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPOST
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}





- (void)sendPostRequest:(NSString * _Nonnull)url
             parameters:(id _Nullable)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(SJSuccessBlock _Nullable)successBlock
                failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPOST
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}





#pragma mark- ============== Request API using PUT method ==============

- (void)sendPutRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPUT
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendPutRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPUT
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendPutRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPUT
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendPutRequest:(NSString * _Nonnull)url
            parameters:(id _Nullable)parameters
             loadCache:(BOOL)loadCache
         cacheDuration:(NSTimeInterval)cacheDuration
               success:(SJSuccessBlock _Nullable)successBlock
               failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodPUT
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
    
}



#pragma mark- ============== Request API using DELETE method ==============

- (void)sendDeleteRequest:(NSString * _Nonnull)url
               parameters:(id _Nullable)parameters
                  success:(SJSuccessBlock _Nullable)successBlock
                  failure:(SJFailureBlock _Nullable)failureBlock{

     [self.requestEngine sendRequest:url
                              method:SJRequestMethodDELETE
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}



- (void)sendDeleteRequest:(NSString * _Nonnull)url
               parameters:(id _Nullable)parameters
                loadCache:(BOOL)loadCache
                  success:(SJSuccessBlock _Nullable)successBlock
                  failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodDELETE
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
    
}




- (void)sendDeleteRequest:(NSString * _Nonnull)url
               parameters:(id _Nullable)parameters
            cacheDuration:(NSTimeInterval)cacheDuration
                  success:(SJSuccessBlock _Nullable)successBlock
                  failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodDELETE
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendDeleteRequest:(NSString * _Nonnull)url
               parameters:(id _Nullable)parameters
                loadCache:(BOOL)loadCache
            cacheDuration:(NSTimeInterval)cacheDuration
                  success:(SJSuccessBlock _Nullable)successBlock
                  failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:SJRequestMethodDELETE
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}





#pragma mark- ============== Request API using specific parameters ==============


- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
    if (parameters) {
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodPOST
                              parameters:parameters
                               loadCache:NO
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
        
    }else{
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodGET
                              parameters:nil
                               loadCache:NO
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    }
}





- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
    if (parameters) {
    
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodPOST
                              parameters:parameters
                               loadCache:loadCache
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
        
    }else{
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodGET
                              parameters:nil
                               loadCache:loadCache
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    }
}




- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
    if (parameters) {
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodPOST
                              parameters:parameters
                               loadCache:NO
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
        
    }else{
        
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodGET
                              parameters:nil
                               loadCache:NO
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    }
}




- (void)sendRequest:(NSString * _Nonnull)url
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
    
    if (parameters) {
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodPOST
                              parameters:parameters
                               loadCache:loadCache
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    }else{
        
        
         [self.requestEngine sendRequest:url
                                  method:SJRequestMethodGET
                              parameters:nil
                               loadCache:loadCache
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    }
}



#pragma mark- ============== Request API using specific request method ==============

- (void)sendRequest:(NSString * _Nonnull)url
             method:(SJRequestMethod)method
         parameters:(id _Nullable)parameters
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
  
     [self.requestEngine sendRequest:url
                              method:method
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendRequest:(NSString * _Nonnull)url
             method:(SJRequestMethod)method
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:method
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendRequest:(NSString * _Nonnull)url
             method:(SJRequestMethod)method
         parameters:(id _Nullable)parameters
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:method
                          parameters:parameters
                           loadCache:NO
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}




- (void)sendRequest:(NSString * _Nonnull)url
             method:(SJRequestMethod)method
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock{
    
     [self.requestEngine sendRequest:url
                              method:method
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}




#pragma mark- ============== Request API uploading ==============


- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                       success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                       failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{
    
    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:NO
                                     parameters:parameters
                                         images:@[image]
                                  compressRatio:1
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
}





- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                 ignoreBaseUrl:(BOOL)ignoreBaseUrl
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                       success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                       failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{

    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:ignoreBaseUrl
                                     parameters:parameters
                                         images:@[image]
                                  compressRatio:1
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];

}




- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{
    
    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:NO
                                     parameters:parameters
                                         images:images
                                  compressRatio:1
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];

}




- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{
    
    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:ignoreBaseUrl
                                     parameters:parameters
                                         images:images
                                  compressRatio:1
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
 
}




- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                 compressRatio:(float)compressRatio
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                       success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                       failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{
    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:NO
                                     parameters:parameters
                                         images:@[image]
                                  compressRatio:compressRatio
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
    

}




- (void)sendUploadImageRequest:(NSString * _Nonnull)url
                 ignoreBaseUrl:(BOOL)ignoreBaseUrl
                    parameters:(id _Nullable)parameters
                         image:(UIImage * _Nonnull)image
                 compressRatio:(float)compressRatio
                          name:(NSString * _Nonnull)name
                      mimeType:(NSString * _Nullable)mimeType
                      progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                       success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                       failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{

    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:ignoreBaseUrl
                                     parameters:parameters
                                         images:@[image]
                                  compressRatio:compressRatio
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
}




- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{
    
     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:NO
                                     parameters:parameters
                                         images:images
                                  compressRatio:compressRatio
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
}




- (void)sendUploadImagesRequest:(NSString * _Nonnull)url
                  ignoreBaseUrl:(BOOL)ignoreBaseUrl
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> * _Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString * _Nonnull)name
                       mimeType:(NSString * _Nullable)mimeType
                       progress:(SJUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(SJUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(SJUploadFailureBlock _Nullable)uploadFailureBlock{

     [self.uploadEngine sendUploadImagesRequest:url
                                  ignoreBaseUrl:ignoreBaseUrl
                                     parameters:parameters
                                         images:images
                                  compressRatio:compressRatio
                                           name:name
                                       mimeType:mimeType
                                       progress:uploadProgressBlock
                                        success:uploadSuccessBlock
                                        failure:uploadFailureBlock];
}




#pragma mark- ============== Request API downloading ==============

- (void)sendDownloadRequest:(NSString * _Nonnull)url
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:NO
                             downloadFilePath:downloadFilePath
                                    resumable:YES
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}



- (void)sendDownloadRequest:(NSString * _Nonnull)url
              ignoreBaseUrl:(BOOL)ignoreBaseUrl
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:ignoreBaseUrl
                             downloadFilePath:downloadFilePath
                                    resumable:YES
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
    
}




- (void)sendDownloadRequest:(NSString * _Nonnull)url
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                  resumable:(BOOL)resumable
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:NO
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}




- (void)sendDownloadRequest:(NSString * _Nonnull)url
              ignoreBaseUrl:(BOOL)ignoreBaseUrl
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                  resumable:(BOOL)resumable
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:ignoreBaseUrl
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}




- (void)sendDownloadRequest:(NSString * _Nonnull)url
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
          backgroundSupport:(BOOL)backgroundSupport
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:NO
                             downloadFilePath:downloadFilePath
                                    resumable:YES
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
    
}




- (void)sendDownloadRequest:(NSString * _Nonnull)url
              ignoreBaseUrl:(BOOL)ignoreBaseUrl
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
          backgroundSupport:(BOOL)backgroundSupport
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:ignoreBaseUrl
                             downloadFilePath:downloadFilePath
                                    resumable:YES
                            backgroundSupport:NO
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
    
}




- (void)sendDownloadRequest:(NSString * _Nonnull)url
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                  resumable:(BOOL)resumable
          backgroundSupport:(BOOL)backgroundSupport
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:NO
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}





- (void)sendDownloadRequest:(NSString * _Nonnull)url
              ignoreBaseUrl:(BOOL)ignoreBaseUrl
           downloadFilePath:(NSString *_Nonnull)downloadFilePath
                  resumable:(BOOL)resumable
          backgroundSupport:(BOOL)backgroundSupport
                   progress:(SJDownloadProgressBlock _Nullable)downloadProgressBlock
                    success:(SJDownloadSuccessBlock _Nullable)downloadSuccessBlock
                    failure:(SJDownloadFailureBlock _Nullable)downloadFailureBlock{
    
    
     [self.downloadEngine sendDownloadRequest:url
                                ignoreBaseUrl:ignoreBaseUrl
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}



#pragma mark- ============== Download suspend operation ==============

- (void)suspendAllDownloadRequests{
    
     [self.downloadEngine suspendAllDownloadRequests];
}




- (void)suspendDownloadRequest:(NSString * _Nonnull)url{
    
     [self.downloadEngine suspendDownloadRequest:url];
}




- (void)suspendDownloadRequest:(NSString * _Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine suspendDownloadRequest:url ignoreBaseUrl:ignoreBaseUrl];
}




- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls{
    
     [self.downloadEngine suspendDownloadRequests:urls];
}




- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine suspendDownloadRequests:urls ignoreBaseUrl:ignoreBaseUrl];
}



#pragma mark- ============== Download resume operation ==============

- (void)resumeAllDownloadRequests{
    
     [self.downloadEngine resumeAllDownloadRequests];
}



- (void)resumeDownloadReqeust:(NSString *_Nonnull)url{
    
     [self.downloadEngine resumeDownloadReqeust:url];
}




- (void)resumeDownloadReqeust:(NSString *_Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine resumeDownloadReqeust:url ignoreBaseUrl:ignoreBaseUrl];
}




- (void)resumeDownloadReqeusts:(NSArray *_Nonnull)urls{
    
     [self.downloadEngine resumeDownloadReqeusts:urls];
}




- (void)resumeDownloadReqeusts:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine resumeDownloadReqeusts:urls ignoreBaseUrl:ignoreBaseUrl];
}



#pragma mark- ============== Download cancel operation ==============

- (void)cancelAllDownloadRequests{
    
     [self.downloadEngine cancelAllDownloadRequests];
}



- (void)cancelDownloadRequest:(NSString * _Nonnull)url{
    
     [self.downloadEngine cancelDownloadRequest:url];
    
}



- (void)cancelDownloadRequest:(NSString * _Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine cancelDownloadRequest:url ignoreBaseUrl:ignoreBaseUrl];
}




- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls{
    
     [self.downloadEngine cancelDownloadRequests:urls];
}




- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
     [self.downloadEngine cancelDownloadRequests:urls ignoreBaseUrl:ignoreBaseUrl];
}



#pragma mark- ============== Download resume data ratio ==============

- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url{
    
    return  [self.downloadEngine resumeDataRatioOfRequest:url];
}



- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url ignoreBaseUrl:(BOOL)ignoreBaseUrl{
    
    return  [self.downloadEngine resumeDataRatioOfRequest:url ignoreBaseUrl:ignoreBaseUrl];
}


#pragma mark- ============== Request Operation ==============

- (void)cancelAllCurrentRequests{
    
    [self.requestPool cancelAllCurrentRequests];
}




- (void)cancelCurrentRequestWithUrl:(NSString *)url{
    
    [self.requestPool cancelCurrentRequestWithUrl:url];
}





- (void)cancelCurrentRequestWithUrl:(NSString * _Nonnull)url
                             method:(NSString * _Nonnull)method
                         parameters:(id _Nullable)parameters{
    
    [self.requestPool cancelCurrentRequestWithUrl:url
                                           method:method
                                       parameters:parameters];
    
}



#pragma mark- ============== Request Info ==============

- (void)logAllCurrentRequests{
    
    [self.requestPool logAllCurrentRequests];
}




- (BOOL)remainingCurrentRequests{
    
    return [self.requestPool remainingCurrentRequests];
}




- (NSInteger)currentRequestCount{
    
    return [self.requestPool currentRequestCount];
}



#pragma mark- ============== Cache Operations ==============


#pragma mark Load cache


- (void)loadCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager loadCacheWithUrl:url completionBlock:completionBlock];
}



- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
         completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager loadCacheWithUrl:url
                                 method:method
                        completionBlock:completionBlock];
}



- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nullable)parameters
         completionBlock:(SJLoadCacheCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager loadCacheWithUrl:url
                                 method:method
                             parameters:parameters
                        completionBlock:completionBlock];
}



#pragma mark calculate cache

- (void)calculateCacheSizeCompletionBlock:(SJCalculateSizeCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager calculateAllCacheSizecompletionBlock:completionBlock];
}



#pragma mark clear cache

- (void)clearAllCacheCompletionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager clearAllCacheCompletionBlock:completionBlock];
}




- (void)clearCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager clearCacheWithUrl:url completionBlock:completionBlock];
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    
    [self.cacheManager clearCacheWithUrl:url
                                  method:method
                         completionBlock:completionBlock];
    
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nonnull)parameters
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    [self.cacheManager clearCacheWithUrl:url
                                  method:method
                              parameters:parameters
                         completionBlock:completionBlock];
    
}

#pragma mark- Setter and Getter


- (SJNetworkRequestPool *)requestPool{
    
    if (!_requestPool) {
         _requestPool = [SJNetworkRequestPool sharedPool];
    }
    return _requestPool;
}



- (SJNetworkCacheManager *)cacheManager{
    
    if (!_cacheManager) {
         _cacheManager = [SJNetworkCacheManager sharedManager];
    }
    return _cacheManager;
}




- (SJNetworkRequestEngine *)requestEngine{
    
    if (!_requestEngine) {
         _requestEngine = [[SJNetworkRequestEngine alloc] init];
    }
    return _requestEngine;
}




- (SJNetworkUploadEngine *)uploadEngine{
    
    if (!_uploadEngine) {
         _uploadEngine = [[SJNetworkUploadEngine alloc] init];
    }
    return _uploadEngine;
}




- (SJNetworkDownloadEngine *)downloadEngine{
    
    if (!_downloadEngine) {
         _downloadEngine = [[SJNetworkDownloadEngine alloc] init];;
    }
    return _downloadEngine;
}

@end
