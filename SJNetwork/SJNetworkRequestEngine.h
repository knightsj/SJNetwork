//
//  SJNetworkRequestManager.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/26.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJNetworkBaseEngine.h"

/* =============================
 *
 * SJNetworkRequestEngine
 *
 * SJNetworkRequestEngine is in charge of sending GET,POST,PUT or DELETE requests.
 *
 * =============================
 */


@interface SJNetworkRequestEngine : SJNetworkBaseEngine



/**
 *  This method offers the most number of parameters of a certain network request.
 *
 *
 *  @note:
 *
 *        1. SJRequestMethod:
 *
 *             a) If the method is set to be 'SJRequestMethodGET', then send GET request
 *             b) If the method is set to be 'SJRequestMethodPOST', then send POST request
 *             c) If the method is set to be 'SJRequestMethodPUT', then send PUT request
 *             d) If the method is set to be 'SJRequestMethodDELETE', then send DELETE request
 *
 *
 *        2. If 'loadCache' is set to be YES, then cache will be tried to
 *           load before sending network request no matter if the cache exists:
 *           If it exists, then load it and callback immediately.
 *           If it dose not exist,then send network request.
 *
 *           If 'loadCache' is set to be NO, then no matter if the cache
 *           exists, network request will be sent.
 *
 *
 *        3. If 'cacheDuration' is set to be large than 0,
 *           then the cache of this request will be written and
 *           the available duration of this cache will be equal to 'cacheDuration'.
 *
 *           So, if the past time is longer than the settled time duration,
 *           the network request will be sent.
 *
 *           If 'cacheDuration' is set to be less or equal to 0, then the cache
 *           of this request will not be written(The unit of cacheDuration is second).
 *
 *
 *
 *  @param url                request url
 *  @param method             request method
 *  @param parameters         parameters
 *  @param loadCache          consider whether to load cache
 *  @param cacheDuration      consider whether to write cache
 *  @param successBlock       success callback
 *  @param failureBlock       failure callback
 *
 */
- (void)sendRequest:(NSString * _Nonnull)url
             method:(SJRequestMethod)method
         parameters:(id _Nullable)parameters
          loadCache:(BOOL)loadCache
      cacheDuration:(NSTimeInterval)cacheDuration
            success:(SJSuccessBlock _Nullable)successBlock
            failure:(SJFailureBlock _Nullable)failureBlock;



@end
