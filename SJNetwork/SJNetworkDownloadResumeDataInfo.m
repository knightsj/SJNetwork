//
//  SJNetworkResumeDataInfo.m
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/28.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkDownloadResumeDataInfo.h"

@implementation SJNetworkDownloadResumeDataInfo

#pragma mark- ============== Life Cycle Methods ==============

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        self.resumeDataRatio = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(resumeDataRatio))];
        self.resumeDataLength = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(resumeDataLength))];
        self.totalDataLength = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(totalDataLength))];
    }    
    return self;
}

#pragma mark- ============== Override Methods ==============

+ (BOOL)supportsSecureCoding {
    
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.resumeDataLength forKey:NSStringFromSelector(@selector(resumeDataLength))];
    [aCoder encodeObject:self.totalDataLength forKey:NSStringFromSelector(@selector(totalDataLength))];
    [aCoder encodeObject:self.resumeDataRatio forKey:NSStringFromSelector(@selector(resumeDataRatio))];
}



- (NSString *)description{
    
    return [NSString stringWithFormat:@"<%@: %p>:{resume data length:%@}, {total data length:%@},{ratio:%@}",NSStringFromClass([self class]), self,_resumeDataLength, _totalDataLength, _resumeDataRatio];
}

@end
