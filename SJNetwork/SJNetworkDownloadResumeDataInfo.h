//
//  SJNetworkResumeDataInfo.h
//  SJNetworkingDemo
//
//  Created by Sun Shijie on 2017/11/28.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import <Foundation/Foundation.h>


/* =============================
 *
 * SJNetworkDownloadResumeDataInfo
 *
 * SJNetworkDownloadResumeDataInfo is in charge of recording the infomation of resume data of the corresponding download request
 *
 * =============================
 */

@interface SJNetworkDownloadResumeDataInfo : NSObject<NSSecureCoding>

// Record the resume data length
@property (nonatomic, readwrite, copy) NSString *resumeDataLength;

// Record total length of the download data
@property (nonatomic, readwrite, copy) NSString *totalDataLength;

// Record the ratio of resume data length and total length of download data (resumeDataLength/dataTotalLength)
@property (nonatomic, readwrite, copy) NSString *resumeDataRatio;


@end

