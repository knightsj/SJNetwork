//
//  SJNetworkHeader.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/12/26.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#ifndef SJNetworkHeader_h
#define SJNetworkHeader_h

#import <AFNetworking/AFNetworking.h>

//Log used to debug
#ifdef DEBUG
#define SJLog(...) NSLog(@"%s line number:%d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define SJLog(...)
#endif


//============== Callbacks: Only for ordinary request ==================//
typedef void(^SJSuccessBlock)(id responseObject);
typedef void(^SJFailureBlock)(NSURLSessionTask *task, NSError *error, NSInteger statusCode);


//============== Callbacks: Only for upload request ==================//
typedef void(^SJUploadSuccessBlock)(id responseObject);
typedef void(^SJUploadProgressBlock)(NSProgress *uploadProgress);
typedef void(^SJUploadFailureBlock)(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *>*uploadFailedImages);


//============== Callbacks: Only for download request ==================//
typedef void(^SJDownloadSuccessBlock)(id responseObject);
typedef void(^SJDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);
typedef void(^SJDownloadFailureBlock)(NSURLSessionTask *task, NSError *error, NSString* resumableDataPath);


/**
 *  HTTP Request method
 */
typedef NS_ENUM(NSInteger, SJRequestMethod) {
    
    SJRequestMethodGET = 60000,
    SJRequestMethodPOST,
    SJRequestMethodPUT,
    SJRequestMethodDELETE,
    
};


/**
 *  Request type
 */
typedef NS_ENUM(NSInteger, SJRequestType) {
    
    SJRequestTypeOrdinary = 70000,
    SJRequestTypeUpload,
    SJRequestTypeDownload
    
};


/**
 *  Manual operation by user (start,suspend,resume,cancel)
 */
typedef NS_ENUM(NSInteger, SJDownloadManualOperation) {
    
    SJDownloadManualOperationStart = 80000,
    SJDownloadManualOperationSuspend,
    SJDownloadManualOperationResume,
    SJDownloadManualOperationCancel,
    
};


#endif /* SJNetworkHeader_h */
