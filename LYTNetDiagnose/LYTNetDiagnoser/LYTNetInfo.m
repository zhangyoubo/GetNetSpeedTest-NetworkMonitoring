//
//  NetInfo.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTNetInfo.h"

@implementation LYTNetInfo
-(NSString *)description{
    NSString *netType;
    switch (self.netType) {
        case 0:
            netType = @"未联网";
            break;
        case 1:
            netType = @"2G网络";
        case 2:
            netType = @"3G网络";
            break;
        case 3:
            netType = @"4G网络";
            break;
        case 4:
            netType = @"5G网络";
            break;
        case 5:
            netType = @"wifi网络";
            break;
        default:
            netType = @"未知网络";
            break;
    }
    return [NSString stringWithFormat:@"\n国家:%@\n区域:%@\n省份:%@\n城市:%@\n运营商:%@\n公网地址:%@\n手机IP:%@\n网关地址:%@\nDNS地址:%@\n网络类型:%@\nSIM制式:%@\napp版本:%@\n手机标识别:%@\n",self.country,self.area,self.region,self.city,self.isp,self.publicIP,self.deviceIPAddres,self.gatewayIPAddress,self.localDNSAddress,netType,self.SIMCardProviderCompany,self.appVersion,self.deviceID];
}
@end
