//
//  SJNetworkCacheInfo.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/25.
//  Copyright © 2017年 Shijie. All rights reserved.
//


#import <Foundation/Foundation.h>


/* =============================
 *
 * SJNetworkCacheInfo
 *
 * SJNetworkCacheInfo is in charge of recording the infomation of cache which is related to a specific network request
 *
 * =============================
 */

@interface SJNetworkCacheInfo : NSObject<NSSecureCoding>

// Record the creation date of the cache
@property (nonatomic, readwrite, strong) NSDate *creationDate;

// Record the length of the period of validity (unit is second)
@property (nonatomic, readwrite, strong) NSNumber *cacheDuration;

// Record the app version when the cache is created
@property (nonatomic, readwrite, copy)   NSString *appVersionStr;

// Record the request identifier of the cache
@property (nonatomic, readwrite, copy)   NSString *reqeustIdentifer;

@end
