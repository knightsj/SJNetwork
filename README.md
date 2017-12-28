# SJNetwork

![](https://img.shields.io/badge/build-passing-brightgreen.svg)
![](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
![](https://img.shields.io/badge/language-Objective--C-30A3FC.svg)
![](https://img.shields.io/badge/pod-1.0.1-orange.svg)
[![](https://img.shields.io/badge/blog-JueJin-007FFF.svg)](https://juejin.im/post/5a3f4ae8f265da4322416967)
[![](https://img.shields.io/badge/weibo-%40J__Knight__-ff0000.svg)](https://weibo.com/1929625262/profile?rightmod=1&wvr=6&mod=personinfo&is_all=1)
[![](https://img.shields.io/badge/License-MIT-ff69b4.svg)](https://github.com/knightsj/SJNetwork/blob/master/LICENSE)

## Introduction



SJNetwork provides a high level network request API  based on AFNetworking and inspired by YTKNetwork: generating network request object according to the configuration of a specific network request(url, method, parameters etc.)  and managing requests by the corresponding objects.

Document for Chinese-convenient reader:[中文文档](https://juejin.im/post/5a3f4ae8f265da4322416967)


## Features



- **Ordinary request**: sending GET,POST,PUT,DELETE network request.
  - write and load caches, configure cache available time duration​
- **Upload request**: sending upload image(s) network request
  - one and more than one image uploading and configure compress ratio before uploading​
- **Download request**: sending download file network request
  - resumable or not
  - background downloading supporting or not
- **Default parameters**:default parameters will be added on request body
- **Custom header**: configuring custom request header(key-value)
- **Base url configuration**  : server url of network requests
- **Request management**:canceling one or more than one current network requests; checking current requests' information
- **Cache operation**: writing, loading or clearing one or more than one cache of network requests ; calculating cache size
- **Debug mode switch**: for convenience of debugging






## Usage



### Installation



#### Step1:



**Using Cocoapods**:

``pod 'SJNetwork'``



or 

**Moving** ``SJNetwork``**folder into your project**.



#### Step2：

```objective-c
#import "SJNetwork.h"
```



### Basic Configuration



#### Server url

```objective-c
[SJNetworkConfig sharedConfig].baseUrl = @"http://v.juhe.cn";
```



#### Default parameters

```objective-c
[SJNetworkConfig sharedConfig].defailtParameters = @{@"app_version":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                                                        @"platform":@"iOS"};
```



#### Timeout seconds

```objective-c
[SJNetworkConfig sharedConfig].timeoutSeconds = 30;//default is 20s
```



#### Debug mode

```objective-c
[SJNetworkConfig sharedConfig].debugMode = YES;//default is NO
```





#### Add request header

```objective-c
[[SJNetworkConfig sharedConfig] addCustomHeader:@{@"token":@"2j4jd9s74bfm9sn3"}];
```

or

```objective-c
[[SJNetworkManager sharedManager] addCustomHeader:@{@"token":@"2j4jd9s74bfm9sn3"}];
```



> The input key-value pair will be added in network request header.
>
> If a pair with same key-value dose not exist, then add it, if it exists, then replace it.





### Ordinary Network Request


POST request (none writing or none loading cache):

```objective-c
[[SJNetworkManager sharedManager] sendPostRequest:@"toutiao/index"
                                       parameters:@{@"type":@"top",
                                                    @"key" :@"0c60"}
  
     success:^(id responseObject) {

  } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {

  }];
```



POST request ( writing and loading cache):



```objective-c
[[SJNetworkManager sharedManager] sendPostRequest:@"toutiao/index"
                                       parameters:@{@"type":@"top",
                                                    @"key" :@"0c60"}
                                        loadCache:YES
                                    cacheDuration:180
  success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {

}];
```



> If loadcache is set to be YES, then try to load cache before sending network request.
>
> If cacheDuration is set to be more than 0, then write cache after receiving response object.



Flow chart of cache operation in ordinary requests:

![](http://oih3a9o4n.bkt.clouddn.com/request-blackwhite.png)



### Cache Operation

 

#### Loading cache



Loading cache of a specific network request:

```objective-c
[[SJNetworkManager sharedManager] loadCacheWithUrl:@"toutiao/index"
                                            method:@"POST"
                                        parameters:@{@"type":@"top",
                                                     @"key" :@"0c60"}
                                 completionBlock:^(id  _Nullable cacheObject) {                               
}];
```



Loading cache of network requests share the same request url:

```objective-c
[[SJNetworkManager sharedManager] loadCacheWithUrl:@"toutiao/index"
                                   completionBlock:^(NSArray * _Nullable cacheArr) {
}];
```



Loading cache of network requests which share the same request url and method:

```objective-c
[[SJNetworkManager sharedManager] loadCacheWithUrl:@"toutiao/index"
                                            method:@"POST"
                                   completionBlock:^(NSArray * _Nullable cacheArr) {
}];
```



#### Clearing Cache



Clearing cache of one specific network request:

```objective-c
[[SJNetworkManager sharedManager] clearCacheWithUrl:@"toutiao/index"
                                             method:@"POST"
                                         parameters:@{@"type":@"top",
                                                      @"key" :@"0c60"}
                                    completionBlock:^(BOOL isSuccess) {
}];
```





Clearing cache of network requests share the same request url:

```objective-c
[[SJNetworkManager sharedManager] clearCacheWithUrl:@"toutiao/index"
                                    completionBlock:^(BOOL isSuccess) {
}];
```





Clearing cache of network requests which share the same request url and method:

```objective-c
[[SJNetworkManager sharedManager] clearCacheWithUrl:@"toutiao/index"
                                             method:@"POST"
                                    completionBlock:^(BOOL isSuccess) {
}];
```



#### Calculating Cache

Calculating the size of cache folder:

```objective-c
[[SJNetworkManager sharedManager] calculateCacheSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize, NSString *totalSizeString) {
        
        NSLog(@"file count :%lu and total size:%lu total size string:%@",(unsigned long)fileCount,(unsigned long)totalSize, totalSizeString);
        
}];
```



> **fileCount**:file counts in cache folder
>
> **totalSize**: size of cache folder(unit is byte)
>
> **totalSizeString**:size of cache folder (size of unit)  eg.``file count :5 and total size:1298609 total size string:1.2385 MB``







### Uploading Function

Uploading one image, original size:



```objective-c
[[SJNetworkManager sharedManager]  sendUploadImageRequest:@"api"
                                               parameters:nil
                                                    image:image_1
                                                     name:@"universe"
                                                 mimeType:@"png"
                                                 progress:^(NSProgress *uploadProgress) {
                                                        
  self.progressView.observedProgress = uploadProgress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages) {

}];
```



> Here, the mimeType can be jpg/JPG, png/PNG, jpeg/JPEG and if the user gives a wrong type, the mimeType will be jpg.



Uploading two images, compress ratio is 0.5(note that if the mineType is 'png' or 'PNG', the compressRatio will be useless):



```objective-c
[[SJNetworkManager sharedManager]  sendUploadImagesRequest:@"api"
                                                parameters:nil
                                                    images:@[image_1,image_2]
                                             compressRatio:0.5
                                                      name:@"images"
                                                  mimeType:@"jpg"
                                                  progress:^(NSProgress *uploadProgress) {

  self.progressView.observedProgress = uploadProgress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages) {
                                                    
}];
```





And if the server which is used for uploading is **different from** the server for ordinary requests, you can user this api:

```objective-c
[[SJNetworkManager sharedManager]  sendUploadImagesRequest:@"http://uploads.im/api"
                                               ignoreBaseUrl:YES
                                                  parameters:nil
                                                      images:@[image_1,image_2]
                                               compressRatio:0.5
                                                        name:@"images"
                                                    mimeType:@"jpg"
                                                    progress:^(NSProgress *uploadProgress) {

      self.progressView.observedProgress = uploadProgress;

  } success:^(id responseObject) {

  } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages) {

  }];
```



> Here, setting ignoreBaseUrl to be YES, and the request url should be complete download url.





### Downloading Function:


We support background downloading(using NSURLSessionDownloadTask object ) and none-background downloading(using NSURLSessionDataTask object) , resumable or none-resumable downloading.



|                            | resumable | none-resumable |
| -------------------------- | --------- | -------------- |
| background supporting      | ✅         | ✅              |
| none-background supporting | ✅         | ✅              |



> **Note**:If a none-background supporting downloading is on going then app enters into background, the downloading task will be canceled. And When app enters into foreground again, an ``auto-resume mechanism`` will make the downloading task restart again.





#### Sending download request



Resumable && none-background supporting download reqeust (default configuration):

```objective-c
[[SJNetworkManager sharedManager] sendDownloadRequest:@"wallpaper.jpg"
                                     downloadFilePath:_imageFileLocalPath
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
{
       self.progressView.progress = progress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {

}];
```



None-resumable && none-background supporting download reqeust:

```objective-c
[[SJNetworkManager sharedManager] sendDownloadRequest:@"half-eatch.jpg"
                                     downloadFilePath:_imageFileLocalPath
                                            resumable:NO
                                    backgroundSupport:NO
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) 
{

    self.progressView.progress = progress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {
    
}];
```





Resumable && background supporting download request:

```objective-c
[[SJNetworkManager sharedManager] sendDownloadRequest:@"universe.jpg"
                                     downloadFilePath:_imageFileLocalPath
                                            resumable:YES
                                    backgroundSupport:YES
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
{

    self.progressView.progress = progress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {

}];
```



None-resumable && background supporting download request:

```objective-c
[[SJNetworkManager sharedManager] sendDownloadRequest:@"iceberg.jpg"
                                     downloadFilePath:_imageFileLocalPath
                                            resumable:NO
                                    backgroundSupport:YES
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
{

    self.progressView.progress = progress;

 } success:^(id responseObject) {

 } failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {

 }];
```



Also supports ignoring base url:

```objective-c
[[SJNetworkManager sharedManager] sendDownloadRequest:@"http://oih3a9o4n.bkt.clouddn.com/wallpaper.jpg"
                                        ignoreBaseUrl:YES
                                     downloadFilePath:_imageFileLocalPath
                                             progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress)
{
      self.progressView.progress = progress;

} success:^(id responseObject) {

} failure:^(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath) {

}];
```



#### Suspending download request



Suspending one download  current request:

```objective-c
[[SJNetworkManager sharedManager] suspendDownloadRequest:@"universe.jpg"];
```



Suspending one or more than one current download requests:

```objective-c
[[SJNetworkManager sharedManager] suspendDownloadRequests:@[@"universe.jpg",@"wallpaper.jpg"]];
```



Suspending all current download requests:

```objective-c
[[SJNetworkManager sharedManager] suspendAllDownloadRequests];
```



#### Resuming download request



Resuming one download  suspended request:

```objective-c
[[SJNetworkManager sharedManager] resumeDownloadReqeust:@"universe.jpg"];
```



Resuming one or more than one download requests:

```objective-c
[[SJNetworkManager sharedManager] resumeDownloadReqeusts:@[@"universe.jpg",@"wallpaper.jpg"]];
```



Resuming all current suspended requests:

```objective-c
[[SJNetworkManager sharedManager] resumeAllDownloadRequests];
```





#### Canceling download request



Canceling one download request:

```objective-c
[[SJNetworkManager sharedManager] cancelDownloadRequest:@"universe.jpg"];
```



Canceling one or more than one current download requests:

```objective-c
[[SJNetworkManager sharedManager] cancelDownloadRequests:@[@"universe.jpg",@"wallpaper.jpg"]];
```



Canceling all current download requests:

```objective-c
[[SJNetworkManager sharedManager] cancelAllDownloadRequests];
```





### Request Management



#### Current request(s) Information



Checking if there is remaining current request(s):

```objective-c
BOOL remaining =  [[SJNetworkManager sharedManager] remainingCurrentRequests];
if (remaining) {
    NSLog(@"There is remaining request");
}
```



Calculating count of current request(s):

```objective-c
NSUInteger count = [[SJNetworkManager sharedManager] currentRequestCount];
if (count > 0) {
    NSLog(@"There is %lu requests",(unsigned long)count);
}
```



Logging all current request(s)：

```objective-c
[[SJNetworkManager sharedManager] logAllCurrentRequests];
```



#### Canceling request



Canceling one network request:

```objective-c
[[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"toutiao/index"
                                                       method:@"POST"
                                                   parameters:@{@"type":@"top",
                                                                @"key" :@"0c60"}];
```



Canceling network request(s) with the same url:

```objective-c
[[SJNetworkManager sharedManager] cancelCurrentRequestWithUrl:@"toutiao/index"];
```



Canceling network request(s) with the same urls:

```objective-c
[[SJNetworkManager sharedManager] cancelDownloadRequests:@[@"toutiao/index",@"weixin/query"]];
```



Canceling all current network request(s):

```objective-c
[[SJNetworkManager sharedManager] cancelAllCurrentRequests];
```



 	

### Log Output



If debug mode is set to be yes, detail log will be provided:

```objective-c
[SJNetworkConfig sharedConfig].debugMode = YES;
```



Loading cache before sending network request, but cache is expired:

```objective-c
=========== Load cache info failed, reason:Cache is expired, begin to clear cache...
=========== Load cache failed: Cache info is invalid 
=========== Failed to load cache, start to sending network request...
=========== Start requesting...
=========== url:http://v.juhe.cn/toutiao/index
=========== method:GET
=========== parameters:{
    app_version = 1.0;
    key = 0c60;
    platform = iOS;
    type = top;
}
=========== Request succeed! 
=========== Request url:http://v.juhe.cn/toutiao/index
=========== Response object:{
  code = 200,
  msg = "",
  data = {}
}
=========== Write cache succeed!
=========== cache object: {
  code = 200,
  msg = "",
  data = {}
}
=========== Cache path: /Users/*******/
=========== Available duration: 180 seconds
```



## Acknowledgements



Thanks for these service:

- [JuHe.cn](https://www.juhe.cn/): GET/POST api
- [Uploads.im](http://uploads.im) : Uploading api
- [QINIU](https://portal.qiniu.com/): Multimedia cloud server(for downloading files)



And also thanks for these two excellent framework:

- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [YTKNetwork](https://github.com/yuantiku/YTKNetwork)





## Lisence

SJNetwork is released under the [MIT License](https://github.com/knightsj/SJNetwork/blob/master/LICENSE).







