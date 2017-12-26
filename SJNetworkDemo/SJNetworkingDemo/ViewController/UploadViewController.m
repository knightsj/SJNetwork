//
//  UploadViewController.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/9/9.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "UploadViewController.h"
#import "SJNetwork.h"

@interface UploadViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *uploadOneImageProgress;

@property (weak, nonatomic) IBOutlet UIProgressView *uploadTwoImageProgress;


@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.uploadOneImageProgress.observedProgress = [NSProgress progressWithTotalUnitCount:0];
    self.uploadTwoImageProgress.observedProgress = [NSProgress progressWithTotalUnitCount:0];
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [SJNetworkConfig sharedConfig].baseUrl = @"http://uploads.im";
}

- (IBAction)uploadOneImage:(UIButton *)sender {

    UIImage *image = [UIImage imageNamed:@"image_2.jpg"];
    
    //====================== with baseurl==================//
    
    [[SJNetworkManager sharedManager]  sendUploadImageRequest:@"api"
                                                   parameters:nil
                                                        image:image
                                                compressRatio:0.5
                                                         name:@"color"
                                                     mimeType:@"jpg"
                                                     progress:^(NSProgress *uploadProgress) {
                                                         
        self.uploadOneImageProgress.observedProgress = uploadProgress;
                                                         
    } success:^(id response) {
                                                         
        NSLog(@"upload succeed");
                                                         
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages) {
                                                         
        NSLog(@"upload failed");
        
    }];
    
}


- (IBAction)resetOneProgressView:(UIButton *)sender {
    
    self.uploadOneImageProgress.observedProgress = [NSProgress progressWithTotalUnitCount:0];
}


- (IBAction)uploadTwoImages:(UIButton *)sender {
    
     UIImage *image_3 = [UIImage imageNamed:@"image_3"];
     UIImage *image_4 = [UIImage imageNamed:@"image_4"];
    
    
     [[SJNetworkManager sharedManager] sendUploadImagesRequest:@"http://uploads.im/api"
                                                 ignoreBaseUrl:YES
                                                    parameters:nil
                                                        images:@[image_3,image_4]
                                                 compressRatio:0.5
                                                          name:@"images"
                                                      mimeType:@"png"
                                                      progress:^(NSProgress *uploadProgress) {

        self.uploadTwoImageProgress.observedProgress = uploadProgress;

    } success:^(id response) {
        
        NSLog(@"upload succeed");

    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages) {
        
        NSLog(@"upload failed, failed images:%@",uploadFailedImages);
    }];
    

    
}

- (IBAction)resetTwoProgressView:(UIButton *)sender {
    self.uploadTwoImageProgress.observedProgress = [NSProgress progressWithTotalUnitCount:0];
}



- (IBAction)cancelProgress1Requst:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"api"];
}



- (IBAction)cancelProgress2Request:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"http://uploads.im/api"];
}



- (IBAction)cancelAllRequests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelAllCurrentRequests];
}



- (IBAction)logAllCurrentRequest:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] logAllCurrentRequests];
}




@end
