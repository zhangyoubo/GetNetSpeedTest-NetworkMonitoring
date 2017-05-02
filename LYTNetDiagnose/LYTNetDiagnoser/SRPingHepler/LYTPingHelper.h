//
//  SRPingHelper.h
//  ping
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYTPingHelper;

@protocol SRPingHelperDelegate <NSObject>

@required
/**
 * Report RTT and packet loss rate.
 * Implement this delegate methods to do more.
 */
- (void)didReportSequence:(NSUInteger)seq timeout:(BOOL)isTimeout delay:(NSUInteger)delay packetLoss:(double)lossRate host:(NSString *)ip;

/**
 stop Ping request
 */
- (void)didStopPingRequest;
@end

/**
 * Encapsulation about Apple's SimplePing, both IPv4 and IPv6 are supported.
 * RTT and average packet loss rate
 */
@interface LYTPingHelper : NSObject

@property (nonatomic, weak) id<SRPingHelperDelegate> delegate;

/**
 ping count
 */
@property (nonatomic,assign) NSInteger pingCount;

/**
 * RTT, ms.
 */
@property (nonatomic, readonly) NSUInteger delay;

/**
 * Packet loss rate, percentage.
 */
@property (nonatomic, readonly) double packetLoss; //Packet loss rate.

/**
 * ping's target host：IP Address or domain name.
 * make sure this value is not null before start ping, an exception is throwed otherwise.
 */
@property (nonatomic, copy) NSString *host;


+ (instancetype)sharedInstance;

/**
 * start ping cycle
 * send a ping packet every 2 seconds
 */
- (void)startPing;

/**
 * stop ping cycle
 */
- (void)stopPing;

@end
