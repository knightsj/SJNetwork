//
//  SJNetworkBaseEngine.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/12/26.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJNetworkRequestModel.h"


@interface SJNetworkBaseEngine : NSObject


/**
 *  This method is used to add customed headers, for subclass to override
 */
- (void)addCustomHeaders;



/**
 *  This method is used to add default parameters with custom parameters, for subclass to override
 *
 *  @param parameters        custom parameters
 *
 */
- (id)addDefaultParametersWithCustomParameters:(id)parameters;




/**
 *  This method is used to execute some operation with the request model when the corresponding request succeed, for subclass to override
 *
 *  @param requestModel      request model of a network request
 *
 */
- (void)requestDidSucceedWithRequestModel:(SJNetworkRequestModel *)requestModel;



@end
