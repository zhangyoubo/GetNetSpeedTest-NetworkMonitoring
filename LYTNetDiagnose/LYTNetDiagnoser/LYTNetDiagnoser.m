//
//  LYTNetDiagnoser.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTNetDiagnoser.h"
#import "LYTNetGetAddress.h"
#import "LYTNetWorkReqestTool.h"
#import "LYTNetInfo.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "LYTNetTimer.h"
#import "LYTPingInfo.h"
#import "LYTPingHelper.h"
#import "NSString+NetTool.h"

typedef void(^INFOBlock)(LYTPingInfo * statues);

@interface LYTNetDiagnoser ()<SRPingHelperDelegate>
{
    LYTNetInfo  * _baseNetInfo;
    dispatch_queue_t _requestQueue;
    dispatch_queue_t _serialQueue;
    LYTPingHelper * _netPinger;
}
@property (nonatomic,copy) INFOBlock infoBlock;
@end
@implementation LYTNetDiagnoser
+ (instancetype)shareTool{
    static LYTNetDiagnoser *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[LYTNetDiagnoser alloc] init];
    });
    return tool;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _baseNetInfo = [[LYTNetInfo alloc] init];
        _netPinger = [LYTPingHelper sharedInstance];
        _netPinger.delegate = self;
        _requestQueue = dispatch_queue_create("LYTNetDiagnoserQueue", DISPATCH_QUEUE_CONCURRENT);
        _serialQueue = dispatch_queue_create("LYTNetDiagnoserQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
- (void)startNetScanWithDelegate:(id<LYTNetDiagnoseDelegate>)delegate
{
    if (delegate) {
        _diagnoseDelegate = delegate;
    }
    if([self.diagnoseDelegate respondsToSelector:@selector(diagnoserBeginScan:)]){
        [self.diagnoseDelegate diagnoserBeginScan:self];
    }
    [self setData];
    [[LYTNetWorkReqestTool shareManager] requestMyIPaddressSuccessBlock:^(LYTNetInfo *info) {
        _baseNetInfo.country = info.country;
        _baseNetInfo.area = info.area;
        _baseNetInfo.region = info.region;
        _baseNetInfo.city = info.city;
        _baseNetInfo.isp = info.isp;
        _baseNetInfo.publicIP = info.publicIP;
        if([self.diagnoseDelegate respondsToSelector:@selector(diagnoserBeginScan:)]){
            [self.diagnoseDelegate diagnoserEndScan:self netInfo:_baseNetInfo];
        }
    }];
}
- (void)setData{
    _baseNetInfo.deviceID = [self uniqueAppInstanceIdentifier];
    _baseNetInfo.netType = [LYTNetGetAddress getNetworkTypeFromStatusBar];
    _baseNetInfo.deviceIPAddres = [LYTNetGetAddress deviceIPAddress];
    _baseNetInfo.gatewayIPAddress = [LYTNetGetAddress getGatewayIPAddress];
    _baseNetInfo.localDNSAddress = [LYTNetGetAddress outPutDNSServers];
    _baseNetInfo.SIMCardProviderCompany = [self getNetSIMCardProviderCompany];
    _baseNetInfo.appVersion = [self appVersion];
}
//自身获取
- (NSString *)getLocalIP{
    return _baseNetInfo.deviceIPAddres;
}
- (NSString *)getGatewayIP{
    return _baseNetInfo.gatewayIPAddress;
}
- (NSArray  *)getLocalDNSAddress{
    return _baseNetInfo.localDNSAddress;
}
- (NSString *)getPublicIP{
    return _baseNetInfo.publicIP;
}

- (NETWORK_TYPE)getNetType{
    //判断是否联网以及获取网络类型
    return _baseNetInfo.netType;
}

- (NSString *)getNetSIMCardProviderCompany{
    //运营商信息
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    if (carrier != NULL) {
        return [carrier carrierName];
        //            _ISOCountryCode = [carrier isoCountryCode];
        //            _MobileCountryCode = [carrier mobileCountryCode];
        //            _MobileNetCode = [carrier mobileNetworkCode];
    }
    return @"";
}
/**
 * 获取deviceID
 */
- (NSString *)uniqueAppInstanceIdentifier
{
    NSString *app_uuid = @"";
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    app_uuid = [NSString stringWithString:(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    return app_uuid;
}
- (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//借助外部
- (void)getDNSFromDomain:(NSString *)domainName respose:(void(^)(LYTPingInfo * info))resposeblock{
    dispatch_async(_serialQueue, ^{
        // host地址IP列表
        LYTPingInfo *info = [[LYTPingInfo alloc] init];
        long time_start = [LYTNetTimer getMicroSeconds];
        info.infoArray = [NSArray arrayWithArray:[LYTNetGetAddress getDNSsWithDormain:domainName]];
        long time_duration = [LYTNetTimer computeDurationSince:time_start] / 1000;
        info.durationTime = time_duration;
        info.infoStr = [NSString stringWithFormat:@"DNS解析结果: %@ (%ldms)",[info.infoArray componentsJoinedByString:@", "],time_duration];
        dispatch_async(dispatch_get_main_queue(), ^{
            resposeblock(info);
        });
        
    });
}

- (void)testPingRequestDomain:(NSString *)domainName count:(NSInteger)times respose:(void(^)(LYTPingInfo * info))resposeblock error:(void(^)(NSString *error))errorBlock{
    //纯数字
    if([domainName isIPaddress]){
        [_netPinger setHost:domainName];
        _netPinger.delegate = self;
        _netPinger.pingCount = times;
        [_netPinger startPing];
    }else{
        //域名
        [self getDNSFromDomain:domainName respose:^(LYTPingInfo *info) {
            dispatch_async(_serialQueue, ^{
                if(info.infoArray.count){
                    self.infoBlock =  [resposeblock copy];
                    [_netPinger setHost:info.infoArray[0]];
                    _netPinger.delegate = self;
                    _netPinger.pingCount = times;
                    [_netPinger startPing];
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        errorBlock(@"域名解析失败!!! 请检查域名和网络\n");
                    });
                }
            });
        }];
    }
}

- (void)stopTestPing{
    [_netPinger stopPing];
}

#pragma mark - LYTPingHelperDelegate
- (void)didReportSequence:(NSUInteger)seq timeout:(BOOL)isTimeout delay:(NSUInteger)delay packetLoss:(double)lossRate host:(NSString *)ip{
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.pingDelegate respondsToSelector:@selector(pingDidReportSequence:timeout:delay:packetLoss:host:)]) {
        [self.pingDelegate pingDidReportSequence:seq timeout:isTimeout delay:delay packetLoss:lossRate host:ip];
    }
    });
}
- (void)didStopPingRequest{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.pingDelegate respondsToSelector:@selector(pingDidStopPingRequest)]) {
            [self.pingDelegate pingDidStopPingRequest];
        }
    });
  
}
@end
