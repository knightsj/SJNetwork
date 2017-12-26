//
//  DownLoadViewController.m
//  WWNetwork
//
//  Created by Sun Shijie on 2017/9/9.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "DownLoadViewController.h"
#import "SJNetwork.h"

@interface DownLoadViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progress_resumable;
@property (weak, nonatomic) IBOutlet UIProgressView *progress_none_resumable;
@property (weak, nonatomic) IBOutlet UIProgressView *progress_resumable_background;
@property (weak, nonatomic) IBOutlet UIProgressView *progress_none_resumable_background;


@end

@implementation DownLoadViewController
{
    NSString *_imagesFolder;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];


    //images folder
    _imagesFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
     [SJNetworkConfig sharedConfig].baseUrl = @"http://oih3a9o4n.bkt.clouddn.com";
    
    
    self.progress_resumable.progress = [[SJNetworkManager sharedManager] resumeDataRatioOfRequest:@"wallpaper.jpg"];
    
    self.progress_none_resumable.progress = [[SJNetworkManager sharedManager] resumeDataRatioOfRequest:@"half-eatch.jpg"];
    
    self.progress_resumable_background.progress = [[SJNetworkManager sharedManager] resumeDataRatioOfRequest:@"universe.jpg"];
    
    self.progress_none_resumable_background.progress = [[SJNetworkManager sharedManager] resumeDataRatioOfRequest:@"iceberg.jpg"];
}


#pragma mark- resumable && none background download support

- (IBAction)startResumableDownload:(UIButton *)sender {

    [self p_download1];
}

- (IBAction)suspendResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] suspendDownloadRequest:@"wallpaper.jpg"];
}

- (IBAction)restartResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] resumeDownloadReqeust:@"wallpaper.jpg"];
}

- (IBAction)cancelResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"wallpaper.jpg"];
}



#pragma mark- none resumable && none background download support

- (IBAction)startNoneResumableDownload:(UIButton *)sender {

   [self p_download2];
}

- (IBAction)suspendNoneResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] suspendDownloadRequest:@"half-eatch.jpg"];
}

- (IBAction)restartNoneResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] resumeDownloadReqeust:@"half-eatch.jpg"];
}


- (IBAction)cancelNoneResumableDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"half-eatch.jpg"];
}



#pragma mark- resumable && background download support

- (IBAction)startResumableBackgroundDownload:(UIButton *)sender {

    [self p_download3];
    
}
- (IBAction)suspendResumableBackgroundDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] suspendDownloadRequest:@"universe.jpg"];
}

- (IBAction)restartResumableBackgroundDownload:(UIButton *)sender {
    
     [[SJNetworkManager sharedManager] resumeDownloadReqeust:@"universe.jpg"];
}


- (IBAction)cancelResumableBackgroundDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"universe.jpg"];
}


#pragma mark- none resumable && background download support

- (IBAction)startNoneResumableBackgroundDownload:(UIButton *)sender {
    
    [self p_download4];
}


- (IBAction)suspendNoneResumableBackgroundDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] suspendDownloadRequest:@"iceberg.jpg"];
}


- (IBAction)restartNoneResumableBackgroundDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] resumeDownloadReqeust:@"iceberg.jpg"];
}

- (IBAction)cancelNoneResumableBackgroundDownload:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelDownloadRequest:@"iceberg.jpg"];
}


#pragma mark- all current download requests operation

- (IBAction)suspendAllDownloadRequests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] suspendAllDownloadRequests];
}


- (IBAction)resumeAllDownloadRequests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] resumeAllDownloadRequests];
}

- (IBAction)cancelAllDownloadRequests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelAllDownloadRequests];
}


- (IBAction)logAllCurrentRequests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] logAllCurrentRequests];
}


- (void)p_download1{
    
    //resumable && none background download support
    [[SJNetworkManager sharedManager] sendDownloadRequest:@"wallpaper.jpg"
                                         downloadFilePath:_imagesFolder
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
    {
          self.progress_resumable.progress = progress;
                                                     
    } success:^(id responseObject) {
                                                     
          NSLog(@"Download succeed!");
                                                     
    } failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {
                                                     
          NSLog(@"Download failed!");
                                                     
    }];
}

- (void)p_download2{
    
    //none resumable && none background download support
    [[SJNetworkManager sharedManager] sendDownloadRequest:@"half-eatch.jpg"
                                         downloadFilePath:[_imagesFolder stringByAppendingPathComponent:@"half-eatch.jpg"]
                                                resumable:NO
                                        backgroundSupport:NO
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
    {
                                                     
        self.progress_none_resumable.progress = progress;
                                                     
    } success:^(id responseObject) {
        
        NSLog(@"Download succeed!");
        
    } failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {
     
        NSLog(@"Download failed!");
    }];
}


- (void)p_download3{
    
    //resumable &&  background download support
    [[SJNetworkManager sharedManager] sendDownloadRequest:@"universe.jpg"
                                         downloadFilePath:[_imagesFolder stringByAppendingPathComponent:@"universe.jpg"]
                                                resumable:YES
                                        backgroundSupport:YES
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
    {
                                                     
        self.progress_resumable_background.progress = progress;
                                                     
    } success:^(id responseObject) {
        
         NSLog(@"Download succeed!");
        
    } failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {
        
         NSLog(@"Download failed!");
        
    }];
}

- (void)p_download4{
    
    //none resumable &&  background download support
    [[SJNetworkManager sharedManager] sendDownloadRequest:@"iceberg.jpg"
                                         downloadFilePath:[_imagesFolder stringByAppendingPathComponent:@"iceberg.jpg"]
                                                resumable:NO
                                        backgroundSupport:YES
                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
    {
                                                     
        self.progress_none_resumable_background.progress = progress;
                                                     
     } success:^(id response) {
         
         NSLog(@"Download succeed!");
         
     } failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {
         
          NSLog(@"Download failed!");
         
     }];
    
}
@end
