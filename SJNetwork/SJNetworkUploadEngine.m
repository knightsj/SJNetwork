//
//  SJNetworkUploadManager.m
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/26.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkUploadEngine.h"
#import "SJNetworkRequestPool.h"
#import "SJNetworkConfig.h"
#import "SJNetworkUtils.h"
#import "SJNetworkProtocol.h"

@interface SJNetworkUploadEngine()<SJNetworkProtocol>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation SJNetworkUploadEngine
{
     BOOL _isDebugMode;
}

#pragma mark- ============== Life Cycle ==============


- (instancetype)init{
    
    self = [super init];
    if (self) {
        
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
    
    //if images count equals 0, then return
    if ([images count] == 0) {
        SJLog(@"=========== Upload image failed:There is no image to upload!");
        return;
    }

    
    //default method is POST
    NSString *methodStr = @"POST";
    
    //generate full request url
    NSString *completeUrlStr = nil;
    
    //generate a unique identifer of a spectific request
    NSString *requestIdentifer = nil;
    
    if (ignoreBaseUrl) {
        
        completeUrlStr   = url;
        requestIdentifer = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:nil
                                                                   requestUrlStr:url
                                                                       methodStr:methodStr
                                                                      parameters:parameters];
    }else{
        
        completeUrlStr   = [[SJNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                   requestUrlStr:url
                                                                       methodStr:methodStr
                                                                      parameters:parameters];
    }
    
    //add custom headers
    [self addCustomHeaders];
    
    //add default parameters
    NSDictionary * completeParameters = [self addDefaultParametersWithCustomParameters:parameters];
    
    //create corresponding request model and send request with it
    SJNetworkRequestModel *requestModel = [[SJNetworkRequestModel alloc] init];
    requestModel.requestUrl = completeUrlStr;
    requestModel.uploadUrl = url;
    requestModel.method = methodStr;
    requestModel.parameters = completeParameters;
    requestModel.uploadImages = images;
    requestModel.imageCompressRatio = compressRatio;
    requestModel.imagesIdentifer = name;
    requestModel.mimeType = mimeType;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.uploadSuccessBlock = uploadSuccessBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    requestModel.uploadFailedBlock = uploadFailureBlock;
    
    [self p_sendUploadImagesRequestWithRequestModel:requestModel];
}



#pragma mark- ============== Private Methods ==============

- (void)p_sendUploadImagesRequestWithRequestModel:(SJNetworkRequestModel *)requestModel{
    
    
    if (_isDebugMode) {
        SJLog(@"=========== Start upload request with url:%@...",requestModel.requestUrl);
    }
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *uploadTask = [_sessionManager POST:requestModel.requestUrl
                                                  parameters:requestModel.parameters
                                   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                       
                                       [requestModel.uploadImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
                                           
                                           //image compress ratio
                                           float ratio = requestModel.imageCompressRatio;
                                           if (ratio > 1 || ratio < 0) {
                                               ratio = 1;
                                           }
                                           
                                           //image data
                                           NSData *imageData = nil;
                                           
                                           //image type
                                           NSString *imageType = nil;
                                           
                                           if ([requestModel.mimeType isEqualToString:@"png"] || [requestModel.mimeType isEqualToString:@"PNG"]  ) {
                                               
                                               imageData = UIImagePNGRepresentation(image);
                                               imageType = @"png";
                                               
                                           }else if ([requestModel.mimeType isEqualToString:@"jpg"] || [requestModel.mimeType isEqualToString:@"JPG"] ){
                                               
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpg";
                                               
                                           }else if ([requestModel.mimeType isEqualToString:@"jpeg"] || [requestModel.mimeType isEqualToString:@"JPEG"] ){
                                               
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpeg";
                                               
                                           }else{
                                               imageData = UIImageJPEGRepresentation(image, ratio);
                                               imageType = @"jpg";
                                           }
                                           
                                                                                      
                                           long index = idx;
                                           NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
                                           long long totalMilliseconds = interval * 1000;
                                           
                                           //file name should be unique
                                           NSString *fileName = [NSString stringWithFormat:@"%lld.%@", totalMilliseconds,imageType];
                                           
                                           //name should be unique
                                           NSString *identifer = [NSString stringWithFormat:@"%@%ld", requestModel.imagesIdentifer, index];
                                           
                                           
                                           [formData appendPartWithFileData:imageData
                                                                       name:identifer
                                                                   fileName:fileName
                                                                   mimeType:[NSString stringWithFormat:@"image/%@",imageType]];
                                       }];
                                       
                                   } progress:^(NSProgress * _Nonnull uploadProgress) {
                                       
                                       if (_isDebugMode){
                                           SJLog(@"=========== Upload image progress:%@",uploadProgress);
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                         if (requestModel.uploadProgressBlock) {
                                             requestModel.uploadProgressBlock(uploadProgress);
                                         }
                                           
                                       });
                                       
                                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                       
                                       if (_isDebugMode){
                                          SJLog(@"=========== Upload image request succeed:%@\n =========== Successfully uploaded images:%@",responseObject,requestModel.uploadImages);
                                       }
                                           
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                         if (requestModel.uploadSuccessBlock) {                                             
                                             requestModel.uploadSuccessBlock(responseObject);
                                         }
                                           
                                         [weakSelf handleRequesFinished:requestModel];
                                           
                                       });
                                       
                                       
                                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                       
                                       
                                       if (_isDebugMode){
                                           SJLog(@"=========== Upload images request failed: \n =========== error:%@\n =========== status code:%ld\n =========== failed images:%@:",error,(long)error.code,requestModel.uploadImages);
                                       }
                                       
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                           if (requestModel.uploadFailedBlock) {
                                               requestModel.uploadFailedBlock(task, error,error.code,requestModel.uploadImages);
                                            }
                                           [weakSelf handleRequesFinished:requestModel];
                                            
                                        });
                                      
                                   }];
    
    requestModel.task = uploadTask;
    [[SJNetworkRequestPool sharedPool] addRequestModel:requestModel];

}




#pragma mark- ============== Override Methods ==============

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
