//
//  SJNetworkProtocol.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/12/6.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJNetworkRequestModel;

@protocol SJNetworkProtocol <NSObject>

@required

/**
 *  This method is used to deal with the request model when the corresponding request is finished
 *
 *  @param requestModel      request model of a network request
 *
 */
- (void)handleRequesFinished:(SJNetworkRequestModel *)requestModel;



@end
