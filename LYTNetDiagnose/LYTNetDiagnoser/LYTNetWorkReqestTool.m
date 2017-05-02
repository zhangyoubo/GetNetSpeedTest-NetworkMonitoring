//
//  NetWorkReqestTool.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTNetWorkReqestTool.h"
#import "LYTNetInfo.h"
@interface LYTNetWorkReqestTool ()<NSURLSessionDelegate>

@end
@implementation LYTNetWorkReqestTool
+ (instancetype)shareManager{
    static LYTNetWorkReqestTool *_shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager =  [[LYTNetWorkReqestTool alloc] init];
    });
    return _shareManager;
}
- (void)requestMyIPaddressSuccessBlock:(void (^)(LYTNetInfo * info))block{
//    NSURL *URL1 = [NSURL URLWithString:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    NSURL *URL2 = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL2];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        LYTNetInfo *info = [[LYTNetInfo alloc] init];

        if (200 == [(NSHTTPURLResponse *)response statusCode]) {
//            NSString *response2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary * json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (json) {
                info.country = json[@"data"][@"country"];
                info.area = json[@"data"][@"area"];
                info.region  = json[@"data"][@"region"];
                info.city = json[@"data"][@"city"];
                info.isp = json[@"data"][@"isp"];
                info.publicIP = json[@"data"][@"ip"];
            }
            block(info);
        }else{
            block(info);
        }
    }];
    [dataTask resume];
}

@end
