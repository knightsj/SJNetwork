//
//  SJNetworkRequestModel.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/17.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkRequestModel.h"
#import "SJNetworkConfig.h"
#import "SJNetworkUtils.h"

@interface SJNetworkRequestModel()

@property (nonatomic, readwrite, copy) NSString *cacheDataFilePath;
@property (nonatomic, readwrite, copy) NSString *cacheDataInfoFilePath;

@property (nonatomic, readwrite, copy) NSString *resumeDataFilePath;
@property (nonatomic, readwrite, copy) NSString *resumeDataInfoFilePath;

@end


@implementation SJNetworkRequestModel

#pragma mark- ============== Public Methods ==============


- (SJRequestType)requestType{
    
    if (self.downloadFilePath){
        
        return SJRequestTypeDownload;
        
    }else if(self.uploadUrl){
        
        return SJRequestTypeUpload;
        
    }else{
        
        return SJRequestTypeOrdinary;
        
    }
}




- (NSString *)cacheDataFilePath{
    
    if (self.requestType == SJRequestTypeOrdinary) {
        
        if (_cacheDataFilePath.length > 0) {
            
            return _cacheDataFilePath;
            
        }else{
            
            _cacheDataFilePath = [SJNetworkUtils cacheDataFilePathWithRequestIdentifer:_requestIdentifer];
            return _cacheDataFilePath;
        }
        
    }else{
        
        return nil;
    }
    
}




- (NSString *)cacheDataInfoFilePath{
    
    
    if (self.requestType == SJRequestTypeOrdinary) {
        
        if (_cacheDataInfoFilePath.length > 0) {
            
            return _cacheDataInfoFilePath;
            
        }else{
            
            _cacheDataInfoFilePath = [SJNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:_requestIdentifer];
            return _cacheDataInfoFilePath;
        }
        
    }else{
        
        return nil;
    }
    
}





- (NSString *)resumeDataFilePath{
    
    if (self.requestType == SJRequestTypeDownload) {
        
        if (_resumeDataFilePath.length > 0) {
            
            return _resumeDataFilePath;
            
        }else{
            
            _resumeDataFilePath = [SJNetworkUtils resumeDataFilePathWithRequestIdentifer:_requestIdentifer downloadFileName:_downloadFilePath.lastPathComponent];
            return _resumeDataFilePath;
        }
        
    }else{
        
        return nil;
        
    }
}




- (NSString *)resumeDataInfoFilePath{
    
    if (self.requestType == SJRequestTypeDownload) {
        
        if (_resumeDataInfoFilePath.length > 0) {
            
            return _resumeDataInfoFilePath;
            
        }else{
            
            _resumeDataInfoFilePath = [SJNetworkUtils resumeDataInfoFilePathWithRequestIdentifer:_requestIdentifer];
            return _resumeDataInfoFilePath;
        }
        
    }else{
        
        return nil;
        
    }
    
}





- (void)clearAllBlocks{
    
    _successBlock = nil;
    _failureBlock = nil;
    
    _uploadProgressBlock = nil;
    _uploadSuccessBlock = nil;
    _uploadFailedBlock = nil;
    
    _downloadProgressBlock = nil;
    _downloadSuccessBlock = nil;
    _downloadFailureBlock= nil;
    
}


#pragma mark- ============== Override Methods ==============

- (NSString *)description{
    
    if ([SJNetworkConfig sharedConfig].debugMode) {
        
        switch (self.requestType) {
                
            case SJRequestTypeOrdinary:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            oridnary request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   loadCache:       %@\n   cacheDuration:   %@ seconds\n   requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_loadCache?@"YES":@"NO",[NSNumber numberWithInteger:_cacheDuration],_requestIdentifer,_task];
                break;
                
            case SJRequestTypeUpload:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            upload request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   images:          %@\n    requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_uploadImages,_requestIdentifer,_task];
                break;
                
            case SJRequestTypeDownload:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            download request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   target path:     %@\n    requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_downloadFilePath,_requestIdentifer,_task];
                break;
                
            default:
                [NSString stringWithFormat:@"\n  request type:unkown request type\n  request object:%@",self];
                break;
        }
        
        
    }else{
        
         return [NSString stringWithFormat:@"<%@: %p>" ,NSStringFromClass([self class]),self];
    }
}

@end
