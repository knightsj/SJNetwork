//
//  SJNetworkRequestModel.h
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SJNetworkHeader.h"


@interface SJNetworkRequestModel : NSObject


//Unique identifier of a request
@property (nonatomic, readwrite, copy)   NSString *requestIdentifer;


//Task of a request (NSURLSessionDataTask or NSURLSessionDownloadTask)
@property (nonatomic, readwrite, strong) NSURLSessionTask *task;


//NSHTTPURLResponse object
@property (nonatomic, readwrite, strong) NSURLResponse *response;


//Request url
@property (nonatomic, readwrite, copy)   NSString *requestUrl;


//If ignore baseUrl(which is set in SJNetworkConfig singleton instance)
@property (nonatomic, readwrite, assign) BOOL ignoreBaseUrl;


//Request method
@property (nonatomic, readwrite, copy)   NSString *method;


//Response object
@property (nonatomic, readwrite, strong) id responseObject;



//============== Only for ordinary request(GET,POST,PUT,DELETE) ==================//

@property (nonatomic, readwrite, strong) id parameters;                             //parameters(request body)
@property (nonatomic, readwrite, assign) BOOL loadCache;                            //if load cache(default is NO)
@property (nonatomic, readwrite, assign) NSTimeInterval cacheDuration;              //if write cache(when bigger than 0, write cache;otherwise don't)
@property (nonatomic, readwrite, strong) NSData *responseData;                      //response data of an ordinary request

@property (nonatomic, readwrite, copy)   SJSuccessBlock successBlock;
@property (nonatomic, readwrite, copy)   SJFailureBlock failureBlock;




//============== Only for upload request ==================//

@property (nonatomic, readwrite, copy)   NSString *uploadUrl;                        //target upload url
@property (nonatomic, readwrite, copy)   NSArray<UIImage *> *uploadImages;           //upload images(or image)array
@property (nonatomic, readwrite, copy)   NSString *imagesIdentifer;                  //identifier of upload image
@property (nonatomic, readwrite, copy)   NSString *mimeType;                         //mime type of upload file
@property (nonatomic, readwrite, assign) float imageCompressRatio;                   //compress ratio of all upload images, default is 1(original)
@property (nonatomic, readonly, copy)    NSString *cacheDataFilePath;                //cache data file path
@property (nonatomic, readonly, copy)    NSString *cacheDataInfoFilePath;            //cache data info file path(record info of corresponding cache data)


@property (nonatomic, readwrite, copy)   SJUploadSuccessBlock uploadSuccessBlock;
@property (nonatomic, readwrite, copy)   SJUploadProgressBlock uploadProgressBlock;
@property (nonatomic, readwrite, copy)   SJUploadFailureBlock uploadFailedBlock;




//============== Only for download request ==================//

@property (nonatomic, readwrite, copy)   NSString *downloadFilePath;                  // target download file path
@property (nonatomic, readwrite, assign) BOOL resumableDownload;                      // if support resumable download, default is YES
@property (nonatomic, readwrite, assign) BOOL backgroundDownloadSupport;              // if support background download, default is NO
@property (nonatomic, readwrite, strong) NSOutputStream *stream;                      // stream used to save download data
@property (nonatomic, readwrite, assign) NSInteger totalLength;                       // total length of download file
@property (nonatomic, readonly, copy)    NSString *resumeDataFilePath;                // resume data file path
@property (nonatomic, readonly, copy)    NSString *resumeDataInfoFilePath;            // resume data info file path
@property (nonatomic, readwrite, assign) SJDownloadManualOperation manualOperation;   // requst operation by user

@property (nonatomic, readwrite, copy)   SJDownloadSuccessBlock downloadSuccessBlock;
@property (nonatomic, readwrite, copy)   SJDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, readwrite, copy)   SJDownloadFailureBlock downloadFailureBlock;




/**
 *  This method is used to return request type of this request
 *
 *  @return requestType               request type of this request
 */
- (SJRequestType)requestType;



/**
 *  This method is used to return the file path of cache data file
 *
 *  @return cacheDataFilePath         file path of cache data file
 */
- (NSString *)cacheDataFilePath;




/**
 *  This method is used to return the file path of cache info data file
 *
 *  @return cacheDataInfoFilePath     file path of cache info data file
 */
- (NSString *)cacheDataInfoFilePath;




/**
 *  This method is used to return the download resume data file path of this request （useful only if this is a download request）
 *
 *  @return resumeDataFilePath        file path of download resume data
 */
- (NSString *)resumeDataFilePath;




/**
 *  This method is used to return the download resume data info file path of this request（useful only if this is a download request）
 *
 *  @return resumeDataInfoFilePath    file path of download resume data info
 */
- (NSString *)resumeDataInfoFilePath;




/**
 *  This method is used to clear all callback blocks
 */
- (void)clearAllBlocks;



@end
