//
//  NetInfo.h
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYTNetDiagnoser.h"
@interface LYTNetInfo : NSObject

/**
 国家
 */
@property (copy, nonatomic) NSString *country;

/**
 区域
 */
@property (copy, nonatomic) NSString *area;

/**
 省份
 */
@property (copy, nonatomic) NSString *region;

/**
 城市
 */
@property (copy, nonatomic) NSString *city;

/**
 提供商
 */
@property (copy, nonatomic) NSString *isp;

/**
 公网iP
 */
@property (copy, nonatomic) NSString *publicIP;

/**
 机器IP
 */
@property (copy, nonatomic) NSString *deviceIPAddres;

/**
 网关地址
 */
@property (copy, nonatomic) NSString *gatewayIPAddress;

/**
 本地DNS
 */
@property (copy, nonatomic) NSArray *localDNSAddress;

/**
 网络类型
 */
@property (assign, nonatomic) NETWORK_TYPE netType;

/**
 获取SIM卡的运营商信息
 */
@property (copy, nonatomic) NSString *SIMCardProviderCompany;

/**
 app版本
 */
@property (copy, nonatomic) NSString *appVersion;

/**
 手机设备ID
 */
@property (copy, nonatomic) NSString *deviceID;
@end
