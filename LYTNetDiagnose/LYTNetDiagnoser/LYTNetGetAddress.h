//
//  LDNetGetAddress.h
//  LDNetDiagnoServiceDemo
//
//  Created by ZhangHaiyang on 15-8-5.
//  Copyright (c) 2015年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LYTNetDiagnoser.h"

@interface LYTNetGetAddress : NSObject


/*!
 * 获取当前设备ip地址
 */
+ (NSString *)deviceIPAddress;


/*!
 * 获取当前设备网关地址
 */
+ (NSString *)getGatewayIPAddress;


/*!
 * 通过域名获取服务器DNS地址
 */
+ (NSArray *)getDNSsWithDormain:(NSString *)hostName;


/*!
 * 获取本地网络的DNS地址
 */
+ (NSArray *)outPutDNSServers;


/*!
 * 获取当前网络类型
 */
+ (NETWORK_TYPE)getNetworkTypeFromStatusBar;

/**
 * 格式化IPV6地址
 */
+(NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr;

@end
