//
//  SJNetworkConfig.h
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

/* =============================
 *
 * SJNetworkConfig
 *
 * SJNetworkConfig is in charge of the configuration of all related network requests
 *
 * =============================
 */

@interface SJNetworkConfig : NSObject

// Base url of requests, default is nil
@property (nonatomic, strong) NSString *_Nullable baseUrl;

// Default parameters, default is nil
@property (nonatomic, strong) NSDictionary * _Nullable defailtParameters;

// Custom headers, default is nil
@property (nonatomic, readonly, strong) NSDictionary * _Nullable customHeaders;

// Request timeout seconds, default is 20 (unit is second)
@property (nonatomic, assign) NSTimeInterval timeoutSeconds;

// If debugMode is set to be YES, then print all detail log
@property (nonatomic, assign) BOOL debugMode;



/**
 *  SJNetworkConfig Singleton
 *
 *  @return sharedConfig singleton instance
 */
+ (SJNetworkConfig *_Nullable)sharedConfig;



/**
 *  This method is used to add request headers (key-value pair(or pairs))
 *
 *  @param header               custom header to be added into request
 *
 */
- (void)addCustomHeader:(NSDictionary *_Nonnull)header;


@end
