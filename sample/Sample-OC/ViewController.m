//
//  ViewController.m
//  Sample-OC
//
//  Created by CavanSu on 2020/8/18.
//  Copyright © 2020 CavanSu. All rights reserved.
//

#import "ViewController.h"
#import <YKNet/YKNet-Swift.h>

@interface ViewController () <YKNetDelegateOC, YKNetLogTubeOC>
@property (nonatomic, strong) YKNetOC *client;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [[YKNetOC alloc] initWithDelegate:self
                                            logTube:self];
    [self getRequest];
}

- (void)getRequest {
    NSString *url = @"https://www.tianqiapi.com/api";
    YKNetRequestEventOC *event = [[YKNetRequestEventOC alloc] initWithName:@"Sample-Get"];
    YKNetRequestTypeObjectOC *type = [[YKNetRequestTypeJsonObjectOC alloc] initWithMethod:YKNetHTTPMethodOCGet
                                                                                url:url];
    
    YKNetRequestTaskOC *task = [[YKNetRequestTaskOC alloc] initWithEvent:event
                                                              type:type
                                                           timeout:10
                                                            header:nil
                                                        parameters:@{@"appid": @"23035354",
                                                                     @"appsecret": @"8YvlPNrz",
                                                                     @"version": @"v9",
                                                                     @"cityid": @"0",
                                                                     @"city": @"%E9%9D%92%E5%B2%9B",
                                                                     @"ip": @"0",
                                                                     @"callback": @"0"}];
    
    [self.client requestWithTask:task
             responseOnQueue:nil
          successCallbackContent:YKNetResponseTypeOCJson
                         success:^(YKNetResponseOC * _Nonnull response) {
        NSLog(@"weather json: %@", response.json);
    } fail:^NSTimeInterval(YKNetErrorOC * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        return 0;
    }];
}

- (void)postRequest {
    NSString *url = @"";
    YKNetRequestEventOC *event = [[YKNetRequestEventOC alloc] initWithName:@"Sample-Post"];
    YKNetRequestTypeObjectOC *type = [[YKNetRequestTypeJsonObjectOC alloc] initWithMethod:YKNetHTTPMethodOCPost
                                                                                url:url];
    
    YKNetRequestTaskOC *task = [[YKNetRequestTaskOC alloc] initWithEvent:event
                                                              type:type
                                                           timeout:10
                                                            header:nil
                                                        parameters:nil];
    
    [self.client requestWithTask:task
                 responseOnQueue:nil
          successCallbackContent:YKNetResponseTypeOCJson
                         success:^(YKNetResponseOC * _Nonnull response) {
        NSLog(@"weather json: %@", response.json);
    } fail:^NSTimeInterval(YKNetErrorOC * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        return 0;
    }];
}

- (void)uploadTask {
    NSString *url = @"";
    YKNetRequestEventOC *event = [[YKNetRequestEventOC alloc] initWithName:@"Sample-Upload"];
    YKNetUploadObjectOC *object = [[YKNetUploadObjectOC alloc] initWithFileKeyOnServer:@"server-input"
                                                                        fileName:@"test"
                                                                        fileData:[[NSData alloc] init]
                                                                            mime:YKNetFileMIMEOCPng];
    
    YKNetUploadTaskOC *task = [[YKNetUploadTaskOC alloc] initWithEvent:event
                                                         timeout:10
                                                          object:object
                                                             url:url
                                                          header:nil
                                                      parameters:nil];
    
    [self.client uploadWithTask:task
                responseOnQueue:nil
         successCallbackContent:YKNetResponseTypeOCBlank
                        success:^(YKNetResponseOC * _Nonnull response) {
        NSLog(@"upload success");
    } fail:^NSTimeInterval(YKNetErrorOC * _Nonnull error) {
        NSLog(@"error: %@", error.localizedDescription);
        return -1;
    }];
}

- (void)downloadTask {
    NSString *url = @"";
    YKNetRequestEventOC *event = [[YKNetRequestEventOC alloc] initWithName:@"Sample-Download"];
    YKNetDownloadObjectOC *object = [[YKNetDownloadObjectOC alloc] initWithTargetDirectory:@""
                                                                               cover:YES];
    YKNetDownloadTaskOC *task = [[YKNetDownloadTaskOC alloc] initWithEvent:event
                                                             timeout:10
                                                              object:object
                                                                 url:url
                                                              header:nil
                                                          parameters:nil];
    
    [self.client downloadWithTask:task
                  responseOnQueue:nil
           successCallbackContent:YKNetResponseTypeOCJson
                         progress:^(float progress) {
        NSLog(@"%f",progress);
    } success:^(YKNetResponseOC * response) {
        NSLog(@"download success");
    } fail:^NSTimeInterval(YKNetErrorOC * error) {
        NSLog(@"error: %@", error.localizedDescription);
        return -1;
    }];
}

#pragma mark - YKNetDelegateOC, ArLogTube
- (void)ykNet:(YKNetOC *)client
requestSuccess:(YKNetRequestEventOC *)event
    startTime:(NSTimeInterval)startTime
          url:(NSString *)url {
    NSLog(@"event: %@, requestSuccess, url: %@", event.name, url);
}

- (void)ykNet:(YKNetOC *)client
  requestFail:(YKNetErrorOC *)error
        event:(YKNetRequestEventOC *)event
          url:(NSString *)url {
    NSLog(@"event: %@, requestFail, url: %@", event.name, url);
}

- (void)logWithInfo:(NSString *)info
              extra:(NSString *)extra {
    NSLog(@"log info: %@, extra: %@", info, extra);
}

- (void)logWithWarning:(NSString *)warning
                 extra:(NSString *)extra {
    NSLog(@"log warning: %@, extra: %@", warning, extra);
}

- (void)logWithError:(YKNetErrorOC *)error
               extra:(NSString *)extra {
    NSLog(@"log error: %@, extra: %@", error, extra);
}
@end
