//
//  SJNetworkConfig.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "SJNetworkConfig.h"

@interface SJNetworkConfig()

@property (nonatomic, readwrite, strong) NSDictionary *customHeaders;

@end

@implementation SJNetworkConfig

+ (SJNetworkConfig *)sharedConfig {
    
    static SJNetworkConfig *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.timeoutSeconds = 20;
    });
    return sharedInstance;
}


- (void)addCustomHeader:(NSDictionary *)header{
    
    if (![header isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if ([[header allKeys] count] == 0) {
        return;
    }
    
    if (!_customHeaders) {
         _customHeaders = header;
        return;
    }
    
    //add custom header
    NSMutableDictionary *headers_m = [_customHeaders mutableCopy];
    [header enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        [headers_m setObject:value forKey:key];
    }];
    
    _customHeaders = [headers_m copy];
    
}


@end
