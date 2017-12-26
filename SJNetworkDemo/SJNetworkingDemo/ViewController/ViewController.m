//
//  ViewController.m
//  SJNetwork
//
//  Created by Sun Shijie on 2017/8/16.
//  Copyright © 2017年 Shijie. All rights reserved.
//

#import "ViewController.h"
#import "SJNetwork.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSString * _url0;
    NSString * _url1;
    NSString * _url2;
    
    NSDictionary *_params_0;
    NSDictionary *_params_1;
    NSDictionary *_params_2;

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [SJNetworkConfig sharedConfig].baseUrl = @"http://v.juhe.cn";
    
    //for request0
    _url0 = @"toutiao/index";
    _params_0 = @{@"key":@"0c604536ac4f8c45fb4b90178bab9285",@"type":@"keji"};
    
    
    //for request1
    _url1 = @"toutiao/index";
    _params_1 = @{@"key":@"0c604536ac4f8c45fb4b90178bab9285",@"type":@"top"};
    
    
    //for request2
    _url2 = @"weixin/query";
    _params_2 = @{@"key":@"d57d833a635f34ac809b61390369e4da"};
}


- (IBAction)sendRequest_1_not_load_cache:(UIButton *)sender {
    
    
    [[SJNetworkManager sharedManager] sendPostRequest:_url1
                                           parameters:_params_1
                                              success:^(id responseObject) {
        
        NSLog(@"request succeed:%@",responseObject);
                                                  
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
        NSLog(@"request failed:%@",error);
    }];
    


}



- (IBAction)sendRequest_1_save_cache:(UIButton *)sender {
    

    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                       cacheDuration:5
                                             success:^(id responseObject) {
                                                 
        NSLog(@"request succeed:%@",responseObject);

        
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
        NSLog(@"request failed:%@",error);
    }];

}



- (IBAction)sendRequest_1_load_cache:(UIButton *)sender {
    

    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                           loadCache:YES
                                       cacheDuration:10
                                             success:^(id responseObject) {

        NSLog(@"request succeed:%@",responseObject);

    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
        NSLog(@"request failed:%@",error);
    }];
    
}

- (IBAction)cancelRequest_1:(UIButton *)sender {
    

//    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:_url1
//                                                           method:@"GET"
//                                                       parameters:_params_1];
    
    [[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:_url1];

}

- (IBAction)loadRequest_1_cache:(UIButton *)sender {
    
//    [[SJNetworkManager sharedManager] loadCacheWithUrl:_url1
//                                                method:@"GET"
//                                            parameters:_params_1
//                                       completionBlock:^(id  _Nullable cacheObject) {
//        NSLog(@"%@",cacheObject);
//    }];
    
    
    [[SJNetworkManager sharedManager] loadCacheWithUrl:_url1 completionBlock:^(NSArray * _Nullable cacheArr) {
        
        NSLog(@"%@",cacheArr);
        
    }];
}



- (IBAction)clearRequest_1_cache:(UIButton *)sender {
    
    
    [[SJNetworkManager sharedManager] clearCacheWithUrl:_url1
                                                 method:@"GET"
                                             parameters:_params_1
                                        completionBlock:^(BOOL isSuccess) {

        if (isSuccess) {
            NSLog(@"Clearing cache successfully!");
        }
    }];
    
    
//    [[SJNetworkManager sharedManager] clearCacheWithUrl:_url1 completionBlock:^(BOOL isSuccess) {
//
//    }];
}




- (IBAction)sendRequest_1_request_2_not_load_cache:(UIButton *)sender {
    
    
//    //send request 0
//    [[SJNetworkManager sharedManager] sendGetRequest:_url0
//                                          parameters:_params_0
//                                             success:^(id responseObject) {
//                                                 
//                                                 NSLog(@"request succeed:%@",responseObject);
//                                                 
//                                             } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
//                                                 
//                                                 NSLog(@"request failed:%@",error);
//                                             }];
    
    //send request 1
    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                             success:^(id responseObject) {
        
         NSLog(@"request succeed:%@",responseObject);
                                                 
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
         NSLog(@"request failed:%@",error);
    }];
    
    
    //send request 2
    [[SJNetworkManager sharedManager] sendGetRequest:_url2
                                          parameters:_params_2
                                             success:^(id responseObject) {
        
        NSLog(@"request succeed:%@",responseObject);
                                                 
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
        NSLog(@"request failed:%@",error);
        
    }];
    
}




- (IBAction)sendRequest_1_request_2_save_cache:(UIButton *)sender {
    
    
    //send request 0
    [[SJNetworkManager sharedManager] sendGetRequest:_url0
                                          parameters:_params_0
                                       cacheDuration:10
                                             success:^(id responseObject) {
                                                 
         NSLog(@"request succeed:%@",responseObject);
                                                 
     } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
         
         NSLog(@"request failed:%@",error);
     }];
    
    //send request 1
    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                       cacheDuration:10
                                             success:^(id responseObject) {
        
         NSLog(@"request succeed:%@",responseObject);
                                                 
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
         NSLog(@"request failed:%@",error);
    }];
    
    
    //send request 2
    [[SJNetworkManager sharedManager] sendGetRequest:_url2
                                          parameters:_params_2
                                       cacheDuration:10
                                             success:^(id responseObject) {
        
        NSLog(@"request succeed:%@",responseObject);
                                                 
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
        NSLog(@"request failed:%@",error);
    }];
    
}




- (IBAction)sendRequest_1_request_2_load_cache:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                           loadCache:YES
                                             success:^(id responseObject) {
        
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
    }];
    
    [[SJNetworkManager sharedManager] sendGetRequest:_url2
                                          parameters:_params_2
                                           loadCache:YES
                                             success:^(id responseObject) {
        
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        
    }];
}

- (IBAction)sendRequest1_request2_save_load_cache:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] sendGetRequest:_url1
                                          parameters:_params_1
                                           loadCache:YES
                                       cacheDuration:10
                                             success:^(id responseObject) {
                                                 
     } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
         
     }];
    
    [[SJNetworkManager sharedManager] sendGetRequest:_url2
                                          parameters:_params_2
                                           loadCache:YES
                                       cacheDuration:10
                                             success:^(id responseObject) {
                                                 
     } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
         
     }];
    
}


- (IBAction)calculate_current_request_count:(UIButton *)sender {
    
    NSUInteger count = [[SJNetworkManager sharedManager] currentRequestCount];
    if (count > 0) {
        NSLog(@"There is %lu requests",(unsigned long)count);
    }
}




- (IBAction)log_all_current_requests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] logAllCurrentRequests];
}




- (IBAction)if_remain_current_requests:(UIButton *)sender {
    
    BOOL remaining =  [[SJNetworkManager sharedManager] remainingCurrentRequests];
    if (remaining) {
        NSLog(@"There is remaining request");
    }
}




- (IBAction)cancel_all_current_requests:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] cancelAllCurrentRequests];
    
}


- (IBAction)clear_all_cache:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] clearAllCacheCompletionBlock:^(BOOL isSuccess) {
        
    }];
    
    
//    [[SJNetworkManager sharedManager] clearAllCacheCompletionBlock:nil];
}




- (IBAction)calculate_cache_size:(UIButton *)sender {
    
    [[SJNetworkManager sharedManager] calculateCacheSizeCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize, NSString *totalSizeString) {
        
        NSLog(@"file count :%lu and total size:%lu total size string:%@",(unsigned long)fileCount,(unsigned long)totalSize, totalSizeString);
        
    }];
    
}


@end
