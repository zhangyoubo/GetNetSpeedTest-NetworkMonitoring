//
//  NetWorkReachability.h
//  SpeedTest
//
//  Created by shen on 17/4/14.
//  Copyright © 2017年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, NetWorkStatus) {
    
    NetWorkStatusNotReachable = 0,
    NetWorkStatusUnknown = 1,
    NetWorkStatusWWAN2G = 2,
    NetWorkStatusWWAN3G = 3,
    NetWorkStatusWWAN4G = 4,
    
    NetWorkStatusWiFi = 9,
};

extern NSString *kNetWorkReachabilityChangedNotification;


@interface NetWorkReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;

- (void)stopNotifier;

- (NetWorkStatus)currentReachabilityStatus;

@end
