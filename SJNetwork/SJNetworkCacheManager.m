//
//  SJNetworkCache.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkCacheManager.h"
#import "SJNetworkRequestModel.h"
#import "SJNetworkConfig.h"
#import "SJNetworkUtils.h"
#import "SJNetworkCacheInfo.h"
#import "SJNetworkDownloadResumeDataInfo.h"



#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif


static dispatch_queue_t sj_cache_io_queue() {
    
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.sj.caching.io", attr);
    });
    
    return queue;
}





@implementation SJNetworkCacheManager{
    
    NSFileManager *_fileManager;
    NSString *_cacheBasePath;
    BOOL _isDebugMode;
}


#pragma mark- ============== Life Cycle Methods ==============


+ (SJNetworkCacheManager *_Nonnull)sharedManager{
    
    static SJNetworkCacheManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[SJNetworkCacheManager alloc] init];
    });
    return sharedManager;
}


- (instancetype)init{
    
    self = [super init];
    if (self) {
        
        _fileManager = [NSFileManager defaultManager];
        _cacheBasePath = [SJNetworkUtils createCacheBasePath];
        _isDebugMode = [SJNetworkConfig sharedConfig].debugMode;
        
    }
    return self;
}

//==================== Write Cache ====================//

#pragma mark- ============== Public Methods ==============


#pragma mark Write Cache

- (void)writeCacheWithReqeustModel:(SJNetworkRequestModel * _Nonnull)requestModel asynchronously:(BOOL)asynchronously{
    
    
    if (asynchronously) {
        
        dispatch_async(sj_cache_io_queue(), ^{
            [self p_wrtieCacheWithRequestModel:requestModel];
        });
        
    }else{
        
        [self p_wrtieCacheWithRequestModel:requestModel];
    }
}



#pragma mark Load Cache



- (void)loadCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock{
    
    NSString *partialIdentifier = [SJNetworkUtils generatePartialIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                           requestUrlStr:url
                                                                               methodStr:nil];
    
    [self p_loadCacheWithPartialIdentifier:partialIdentifier completionBlock:completionBlock];

}


- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
         completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock{
    
    
    NSString *partialIdentifier = [SJNetworkUtils generatePartialIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                           requestUrlStr:url
                                                                               methodStr:method];
    
    [self p_loadCacheWithPartialIdentifier:partialIdentifier completionBlock:completionBlock];
    
}




- (void)loadCacheWithUrl:(NSString * _Nonnull)url
                  method:(NSString * _Nonnull)method
              parameters:(id _Nullable)parameters
         completionBlock:(SJLoadCacheCompletionBlock _Nullable)completionBlock{

    NSString *requestIdentifer = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url
                                                                              methodStr:method
                                                                             parameters:parameters];
    
    [self loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(NSArray * _Nullable cacheArr) {
        
        if (completionBlock) {
            completionBlock(cacheArr);
        }
    
    }];
    
}



- (void)loadCacheWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer
                      completionBlock:(SJLoadCacheCompletionBlock _Nullable)completionBlock{
    
    NSString *cacheDataFilePath = [SJNetworkUtils cacheDataFilePathWithRequestIdentifer:requestIdentifer];
    NSString *cacheInfoFilePath = [SJNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:requestIdentifer];
    
    //load cache info
    SJNetworkCacheInfo *cacheInfo = [self p_loadCacheInfoWithRequestIdentifier:requestIdentifer];
    
    if (!cacheInfo) {
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache failed: Cache info dose not exists in path:%@",cacheInfoFilePath);
        }
        
        [self removeCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        
        return;
    }
    
    BOOL cacheValidation = [self p_checkCacheValidation:cacheInfo];
    
    if (!cacheValidation) {
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache failed: Cache info is invalid");
        }
        
        [self removeCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        
        return;
        
    }
    
    id cacheObject = [self p_loadCacheObjectWithCacheFilePath:cacheDataFilePath];
    
    if (!cacheObject) {
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache failed: Cache data is missing");
        }
        
        [self removeCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        
        return;
        
    }else {
        
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache succeed: Cache loacation:%@",cacheDataFilePath);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(cacheObject);
            }
        });
    }
}




#pragma mark Calculate Cache

- (void)calculateAllCacheSizecompletionBlock:(SJCalculateSizeCompletionBlock _Nullable)completionBlock{

    NSURL *diskCacheURL = [NSURL fileURLWithPath:_cacheBasePath isDirectory:YES];
    
    dispatch_async(sj_cache_io_queue(), ^{
        
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += fileSize.unsignedIntegerValue;
            fileCount += 1;
        }
        
        NSString *totalSizeStr = nil;
        NSUInteger mb = 1024 *1024;
        if (totalSize <mb) {
            totalSizeStr = [NSString stringWithFormat:@"%.4f KB",(totalSize * 1.0/1024)];
        }else{
            totalSizeStr = [NSString stringWithFormat:@"%.4f MB",totalSize * 1.0/(mb)];
        }
        if (_isDebugMode) {
            SJLog(@"=========== Calculate cache size succeed:total fileCount:%ld & totalSize:%@",(unsigned long)fileCount,totalSizeStr);
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{                
                completionBlock(fileCount, totalSize, totalSizeStr);
            });
        }
    });

}


#pragma mark Clear Cache

- (void)clearAllCacheCompletionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{

    dispatch_async(sj_cache_io_queue(), ^{
        
        NSError *removeCacheFolderError = nil;
        NSError *createCacheFolderError = nil;
        [_fileManager removeItemAtPath:_cacheBasePath error:&removeCacheFolderError];
        
        if (!removeCacheFolderError) {
            
            [_fileManager createDirectoryAtPath:_cacheBasePath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&createCacheFolderError];
            
            if (!createCacheFolderError) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                SJLog(@"=========== Clearing all cache successfully");
                if (completionBlock) {
                        completionBlock(YES);
                        return;
                }
                });
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                if (_isDebugMode) {
                    SJLog(@"=========== Clearing cache error: Failed to create cache folder after removing it");
                }
                if(completionBlock) {
                    
                        completionBlock(NO);
                        return;
                      }
                });
              
            }
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isDebugMode) {
                    SJLog(@"=========== Clearing cache error: Failed to remove cache folder");
                }
                if (completionBlock) {
                    completionBlock(NO);
                    return;
                }
            });
               
        };
    });
}



- (void)clearCacheWithUrl:(NSString * _Nonnull)url completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{

    
    NSString *partiticalIdentifier = [SJNetworkUtils generatePartialIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                              requestUrlStr:url
                                                                                  methodStr:nil];
    
    [self p_clearCacheWithIdentifier:partiticalIdentifier completionBlock:completionBlock];
    
}




- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    NSString *partiticalIdentifier = [SJNetworkUtils generatePartialIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                              requestUrlStr:url
                                                                                  methodStr:method];
    
    [self p_clearCacheWithIdentifier:partiticalIdentifier completionBlock:completionBlock];
}




- (void)clearCacheWithUrl:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nullable)parameters
          completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{

    NSString *requestIdentifer = [SJNetworkUtils generateRequestIdentiferWithBaseUrlStr:[SJNetworkConfig sharedConfig].baseUrl
                                                                          requestUrlStr:url
                                                                              methodStr:method
                                                                             parameters:parameters];
    
    [self p_clearCacheWithIdentifier:requestIdentifer completionBlock:completionBlock];
    
}



#pragma mark Update resume data or resume data info

- (void)updateResumeDataInfoAfterSuspendWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel{
    
    NSData *resumeData = requestModel.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
    [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:nil];
    
    int64_t downloadedByte = requestModel.task.countOfBytesReceived;
    int64_t totalByte = requestModel.task.countOfBytesExpectedToReceive;
    CGFloat percent = 1.0 *downloadedByte/totalByte;
    SJNetworkDownloadResumeDataInfo *dataInfo = [self loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
    dataInfo.resumeDataLength = [NSString stringWithFormat:@"%lld",downloadedByte];
    dataInfo.totalDataLength = [NSString stringWithFormat:@"%lld",totalByte];
    dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",percent];
    [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
}




- (void)removeResumeDataAndResumeDataInfoFileWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel{
    
    [_fileManager removeItemAtPath:requestModel.resumeDataFilePath error:nil];
    [_fileManager removeItemAtPath:requestModel.resumeDataInfoFilePath error:nil];
    
}



- (void)removeCompleteDownloadDataAndClearResumeDataInfoFileWithRequestModel:(SJNetworkRequestModel *_Nonnull)requestModel{
    
    NSError *moveFileError = nil;
    [_fileManager moveItemAtPath:requestModel.resumeDataFilePath toPath:requestModel.downloadFilePath error:&moveFileError];
    if (moveFileError.code == 516) {
        [_fileManager removeItemAtPath:requestModel.resumeDataFilePath error:nil];
    }
    [_fileManager removeItemAtPath:requestModel.resumeDataInfoFilePath error:nil];
    
}



- (void)removeCacheDataFile:(NSString *)cacheDataFilePath cacheInfoFile:(NSString *)cacheInfoFilePath{
    
    if([_fileManager fileExistsAtPath:cacheDataFilePath]){
        [_fileManager removeItemAtPath:cacheDataFilePath error:nil];
    }
    
    if([_fileManager fileExistsAtPath:cacheInfoFilePath]){
        [_fileManager removeItemAtPath:cacheInfoFilePath error:nil];
    }
    
}

#pragma mark load resume data info


- (SJNetworkDownloadResumeDataInfo *)loadResumeDataInfo:(NSString *)filePath {
    
    SJNetworkDownloadResumeDataInfo *dataInfo = nil;
    if ([_fileManager fileExistsAtPath:filePath isDirectory:nil]) {
        dataInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if ([dataInfo isKindOfClass:[SJNetworkDownloadResumeDataInfo class]]) {
            return dataInfo;
        }else{
            return nil;
        }
    }
    return nil;
}





#pragma mark- ============== Private Methods ==============


- (void)p_wrtieCacheWithRequestModel:(SJNetworkRequestModel *)requestModel{
    
    if (requestModel.responseData) {
        
        //path of cache file
        [requestModel.responseData writeToFile:requestModel.cacheDataFilePath atomically:YES];
        
        //write cache info data
        SJNetworkCacheInfo *cacheInfo = [[SJNetworkCacheInfo alloc] init];
        cacheInfo.creationDate = [NSDate date];
        cacheInfo.cacheDuration = [NSNumber numberWithInteger:requestModel.cacheDuration];
        cacheInfo.appVersionStr = [SJNetworkUtils appVersionStr];
        cacheInfo.reqeustIdentifer = requestModel.requestIdentifer;
        
        //write cache info
        [NSKeyedArchiver archiveRootObject:cacheInfo toFile:requestModel.cacheDataInfoFilePath];
        
        if (_isDebugMode) {
            SJLog(@"=========== Write cache succeed!\n =========== cache object: %@\n =========== Cache path: %@\n =========== Available duration: %@ seconds",requestModel.responseObject,requestModel.cacheDataFilePath,cacheInfo.cacheDuration);
        }
        
    }else{
        if (_isDebugMode) {
            SJLog(@"=========== Write cache failed! reason: There is no responeseData");
        }
    }
}

- (void)p_loadCacheWithPartialIdentifier:(NSString *)partialIdentifier completionBlock:(SJLoadCacheArrCompletionBlock _Nullable)completionBlock{
    
    
    NSDirectoryEnumerator *enumerator = [_fileManager enumeratorAtPath:_cacheBasePath];
    NSMutableArray *requestIdentifersArr = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    for (NSString *fileName in enumerator){
        
        if ([fileName containsString:partialIdentifier]) {
            
            if ([fileName containsString:SJNetworkCacheFileSuffix]) {
                
                NSString *identifier = [fileName substringWithRange:NSMakeRange(0, (fileName.length - SJNetworkCacheFileSuffix.length - 1))];
                [requestIdentifersArr addObject:identifier];
                
            }else{
                //do not match cache data file
            }
        }
    }
    
    if ([requestIdentifersArr count] > 0) {
        NSMutableArray *cacheObjArr = [[NSMutableArray alloc] initWithCapacity:2];
        
        for (NSString* requestIdentifer in requestIdentifersArr) {
            [self loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(id  _Nullable cacheObject) {
                if (cacheObject) {
                    [cacheObjArr addObject:cacheObject];
                }
            }];
        }
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache succeed: Found cache corresponding this url");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock([cacheObjArr copy]);
            }
        });
        
        
        
    }else{
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache failed: There is no any cache corresponding this url");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
    
}


- (BOOL)p_checkCacheValidation:(SJNetworkCacheInfo *)cacheInfo{
    
    if (!cacheInfo || ![cacheInfo isKindOfClass:[SJNetworkCacheInfo class]]) {
        return NO;
    }
    
    //check duration
    NSDate *creationDate = cacheInfo.creationDate;
    NSTimeInterval pastDuration = - [creationDate timeIntervalSinceNow];
    NSTimeInterval cacheDuration = [cacheInfo.cacheDuration integerValue];
    
    if (cacheDuration <= 0 ) {
        if (_isDebugMode) {
            SJLog(@"=========== Load cache info failed, reason: Did not set duration time, begin to clear cache...");
        }
        [self p_clearCacheWithIdentifier:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    
    if (pastDuration < 0 || pastDuration > cacheDuration) {
        
        if (_isDebugMode) {
            SJLog(@"=========== Load cache info failed, reason:Cache is expired, begin to clear cache...");
        }
        
        [self p_clearCacheWithIdentifier:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    
    //check app version
    NSString *cacheAppVersionStr = cacheInfo.appVersionStr;
    NSString *currentAppVersionStr = [SJNetworkUtils appVersionStr];
    
    if ( (!cacheAppVersionStr) && (!currentAppVersionStr)) {
        if (_isDebugMode) {
            SJLog(@"=========== Load cache info failed, reason: Failed to load app version, begin to clear cache...");
        }
        [self p_clearCacheWithIdentifier:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    if (cacheAppVersionStr.length != currentAppVersionStr.length || ![cacheAppVersionStr isEqualToString:currentAppVersionStr]) {
        if (_isDebugMode) {
            SJLog(@"=========== Load cache info failed, reason: Failed to match app version, begin to clear cache...");
        }
        [self p_clearCacheWithIdentifier:cacheInfo.reqeustIdentifer completionBlock:nil];
        return NO;
    }
    
    return YES;
    
}



- (void)p_clearCacheWithIdentifier:(NSString *)identifier completionBlock:(SJClearCacheCompletionBlock _Nullable)completionBlock{
    
    
    NSMutableArray *deleteFileNamesArr = [[NSMutableArray alloc] initWithCapacity:2];
    NSDirectoryEnumerator *enumerator = [_fileManager enumeratorAtPath:_cacheBasePath];
    
    for (NSString *fileName in enumerator){
        if ([fileName containsString:identifier]) {
            NSString *deleteFilePath = [_cacheBasePath stringByAppendingPathComponent:fileName];
            [deleteFileNamesArr addObject:deleteFilePath];
        }
    }
    
    if ([deleteFileNamesArr count] > 0) {
        
        for (NSInteger index = 0; index < deleteFileNamesArr.count; index++) {
            
            dispatch_async(sj_cache_io_queue(), ^{
                
                [_fileManager removeItemAtPath:deleteFileNamesArr[index] error:nil];
                
                if (index == deleteFileNamesArr.count - 1) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_isDebugMode) {
                            SJLog(@"=========== Clearing cache successfully!");
                        }
                        if (completionBlock) {
                            completionBlock(YES);
                            return;
                        }
                    });
                }
            });
            
        }
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_isDebugMode) {
                SJLog(@"=========== Clearing cache error: there is no corresponding cache info");
            }
            if (completionBlock) {
                completionBlock(NO);
                return;
            }
        });
        
    }
    
}



- (id)p_loadCacheObjectWithCacheFilePath:(NSString *)cacheFilePath{
    
    id cacheObject = nil;
    NSError *error = nil;
    
    if ([_fileManager fileExistsAtPath:cacheFilePath isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:cacheFilePath];
        cacheObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error];
        if (cacheObject) {
            return cacheObject;
        }
    }
    return cacheObject;
}



- (SJNetworkCacheInfo *)p_loadCacheInfoWithRequestIdentifier:(NSString *)requestIdentifer {
    
    NSString *cacheInfoFilePath = [SJNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:requestIdentifer];
    
    SJNetworkCacheInfo *cacheInfo = nil;
    if ([_fileManager fileExistsAtPath:cacheInfoFilePath isDirectory:nil]) {
        
        cacheInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheInfoFilePath];
        if ([cacheInfo isKindOfClass:[SJNetworkCacheInfo class]]) {
            return cacheInfo;
        }else{
            return nil;
        }
    }
    return nil;
}


@end
