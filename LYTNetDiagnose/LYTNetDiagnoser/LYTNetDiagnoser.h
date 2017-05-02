//
//  LYTNetDiagnoser.h
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYTPingInfo.h"
//网络类型
typedef enum {
    NETWORK_TYPE_NONE = 0,//未连接网络
    NETWORK_TYPE_2G = 1,
    NETWORK_TYPE_3G = 2,
    NETWORK_TYPE_4G = 3,
    NETWORK_TYPE_5G = 4,  //  5G目前为猜测结果
    NETWORK_TYPE_WIFI = 5,
} NETWORK_TYPE;
@class LYTNetDiagnoser;
@class LYTNetInfo;
@protocol LYTNetDiagnoseDelegate <NSObject>

/**
 开始扫描
 */
- (void)diagnoserBeginScan:(LYTNetDiagnoser *)dignoser;

/**
 停止扫描
 */
- (void)diagnoserErrorScan:(LYTNetDiagnoser *)dignoser errorInfo:(LYTNetInfo *)errorInfo;

/**
 扫描完毕
 @param info 获取得到的网络信息
 */
- (void)diagnoserEndScan:(LYTNetDiagnoser *)dignoser netInfo:(LYTNetInfo *)info;


@end
@protocol LYTNetPingDelegate <NSObject>

- (void)pingDidReportSequence:(NSUInteger)seq timeout:(BOOL)isTimeout delay:(NSUInteger)delay packetLoss:(double)lossRate host:(NSString *)ip;

- (void)pingDidStopPingRequest;
@end

@interface LYTNetDiagnoser : NSObject
@property (weak, nonatomic) id<LYTNetDiagnoseDelegate> diagnoseDelegate;
@property (weak, nonatomic) id<LYTNetPingDelegate> pingDelegate;

+ (instancetype)shareTool;

/**
 开始扫描

 @param delegate 扫描状态传递给代理
 */
- (void)startNetScanWithDelegate:(id<LYTNetDiagnoseDelegate>)delegate;

//自身获取
- (NSString *)getLocalIP;
- (NSString *)getGatewayIP;
- (NSArray  *)getLocalDNSAddress;
- (NSString *)getPublicIP;
- (NSString *)getNetSIMCardProviderCompany;
- (NETWORK_TYPE )getNetType;

/**
 DNS解析

 @param domainName 域名 eg ”www.baidu.com"
 @param resposeblock 回调DNS解析的结果
 */
- (void)getDNSFromDomain:(NSString *)domainName respose:(void(^)(LYTPingInfo * info))resposeblock;

/**
 ping 域名延迟测试

 @param domainName 域名或者host eg “www.baidu.com"、“8.8.8.8”
 @param times 次数
 @param resposeblock 结果
 */
- (void)testPingRequestDomain:(NSString *)domainName count:(NSInteger)times respose:(void(^)(LYTPingInfo * info))resposeblock error:(void(^)(NSString *error))errorBlock;

/**
 停止ping测试
 */
- (void)stopTestPing;
@end
