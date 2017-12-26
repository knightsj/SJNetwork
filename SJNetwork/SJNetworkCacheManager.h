//
//  SJNetworkCache.h
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJNetworkRequestModel;
@class SJNetworkDownloadResumeDataInfo;


// Callback when the cache is cleared
typedef void(^SJClearCacheCompletionBlock)(BOOL isSuccess);

// Callback when the cache is loaded
typedef void(^SJLoadCacheCompletionBlock)(id _Nullable cacheObject);

// Callback when cache array is loaded
typedef void(^SJLoadCacheArrCompletionBlock)(NSArray * _Nullable cacheArr);

// Callback when the size of cache is calculated
typedef void(^SJCalculateSizeCompletionBlock)(NSUInteger fileCount, NSUInteger totalSize, NSString * _Nonnull totalSizeString);



/* =============================
 *
 * SJNetworkCacheManager
 *
 * SJNetworkCacheManager is in charge of managing operations of oridinary request cache(and cache info) and resume data (and resume data info)of a certain download request
 *
 * =============================
 */

@interface SJNetworkCacheManager : NSObject



/**
 *  SJNetworkCacheManager Singleton
 *
 *  @return SJNetworkCacheManager singleton instance
 */
+ (SJNetworkCacheManager *_Nonnull)sharedManager;





//============================ Write Cache ============================//

/**
 *  This method is used to write cache(cache data and cache info), 
    can only be called by SJNetworkManager instance
 *
 *  @param requestModel        the model holds the configuration of a specific request
 *  @param asynchronously      if write cache asynchronously
 *
 */
- (void)writeCacheWithReqeustModel:(SJNetworkRequestModel * _Nonnull)requestModel asynchronously:(BOOL)asynchronously;




//============================= Load cache =============================//


/**
 *  This method is used to load cache which is related to a specific url,
    no matter what request method is or parameters are
 *
 *
 *  @param url                  the url of related network requests
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock;




- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
         completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock;



/**
 *  This method is used to load cache which is related to a specific url,method and parameters
 *
 *  @param url                  the url of the network request
 *  @param method               the method of the network request
 *  @param parameters           the parameters of the network request
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nullable)parameters
         completionBlock:(SJLoadCacheCompletionBlock _Nullable)completionBlock;





/**
 *  This method is used to load cache which is related to a identier which is the unique to a network request,
    can only be called by SJNetworkManager instance
 *
 *  @param requestIdentifer     the unique identier of a specific  network request
 *  @param completionBlock      callback
 *
 */
- (void)loadCacheWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer completionBlock:(SJLoadCacheCompletionBlock _Nullable)completionBlock;





//============================ calculate cache ============================//

/**
 *  This method is used to calculate the size of the cache folder (include ordinary request cache and download resume data file and resume data info file)
 *
 *  @param completionBlock      finish callback
 *
 */
- (void)calculateAllCacheSizecompletionBlock:(SJCalculateSizeCompletionBlock _Nullable)completionBlock;





//============================== clear cache ==============================//

/**
 *  This method is used to clear all cache which is in the cache folder
 *
 *  @param completionBlock      callback
 *
 */
- (void)clearAllCacheCompletionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock;




/**
 *  This method is used to clear the cache which is related the specific url,
    no matter what request method is or parameters are
 *
 *  @param url                   the url of network request
 *  @param completionBlock       callback
 *
 */
- (void)clearCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock;




- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock;


/**
 *  This method is used to clear cache which is related to a specific url,method and parameters
 *
 *  @param url                  the url of the network request
 *  @param method               the method of the network request
 *  @param parameters           the parameters of the network request
 *  @param completionBlock      callback
 *
 */
- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nullable)parameters
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock;



//============================== Update resume data or resume data info ==============================//

/**
 *  This method is used to update resume data info after suspending a download request
 *
 *  @param requestModel      request model of a network requst
 *
 */
- (void)updateResumeDataInfoAfterSuspendWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel;




/**
 *  This method is used to remove resume data and resume data info files
 *
 *  @param requestModel      request model of a network requst
 *
 */
- (void)removeResumeDataAndResumeDataInfoFileWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel;





/**
 *  This method is used to remove download data to target download file path and clear the resume data info file
 *
 *  @param requestModel      request model of a network requst
 *
 */
- (void)removeCompleteDownloadDataAndClearResumeDataInfoFileWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel;




//============================== Load resume data info ==============================//

/**
 *  This method is used to load resume data info in a given file path
 *
 *  @param filePath          file path
 *
 */
- (SJNetworkDownloadResumeDataInfo *_Nullable)loadResumeDataInfo:(NSString *_Nonnull)filePath;


@end
