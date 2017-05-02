//
//  SRPingHelper.m
//  ping
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 cvte. All rights reserved.
//

#import "LYTPingHelper.h"
#import "LYTSimplePing.h"
#include <netdb.h>
#include <sys/socket.h>


#define PING_TIME_INTERVAL  2.0

#define PING_TIMEOUT_DELAY  1000

#define PING_afterDelay 1.5

@interface LYTPingHelper ()<SimplePingDelegate>
{
    NSString *_hostAddress; //目标域名的IP地址

}
@property (nonatomic) NSTimeInterval startTimeInterval;

@property (nonatomic, assign) NSUInteger delay;

@property (nonatomic, assign) double packetLoss;

@property (nonatomic) NSUInteger sendPackets;

@property (nonatomic) NSUInteger receivePackets;

@property (nonatomic, strong) NSTimer *pingTimer;

@property (nonatomic, strong) LYTSimplePing *simplePing;

@property (nonatomic,strong) dispatch_queue_t ping_queue;

@end

@implementation LYTPingHelper

- (id)init
{
    if (self = [super init]) {
        _pingCount = 10;
    }
    return self;
}
- (dispatch_queue_t)ping_queue{
    if (_ping_queue == NULL) {
        _ping_queue = dispatch_queue_create("com.myhost.ping", DISPATCH_QUEUE_SERIAL);
    }
    return _ping_queue;
}

+ (instancetype)sharedInstance
{
    static id pingHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pingHelper = [[self alloc] init];
    });
    return pingHelper;
}

- (void)startPing
{
    if (self.host.length > 0) {
        self.sendPackets = 0;
        self.receivePackets = 0;
        dispatch_async(self.ping_queue, ^{
            self.pingTimer = [NSTimer timerWithTimeInterval:PING_TIME_INTERVAL target:self selector:@selector(doPing) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] run];
        });
    } else {
        NSException *exception = [NSException exceptionWithName:@"Null Host" reason:@"Host is Null" userInfo:nil];
        @throw exception;
    }
}

- (void)stopPing
{
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    self.delay = 0;
    self.packetLoss = 0;
    self.ping_queue = NULL;
    
    
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(LYTSimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [pinger sendPingWithData:nil];
    //提前ip地址
    _hostAddress = [self DisplayAddressForAddress:address];
    
}

- (void)simplePing:(LYTSimplePing *)pinger didFailWithError:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
}

- (void)simplePing:(LYTSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    self.sendPackets++;
    
    self.startTimeInterval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)simplePing:(LYTSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
}

- (void)simplePing:(LYTSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeout) object:nil];
    [self clearSimplePing];
    
    self.receivePackets++;
    
    self.delay = ([NSDate timeIntervalSinceReferenceDate] - self.startTimeInterval) * 1000;
    self.packetLoss = (double)((self.sendPackets - self.receivePackets) * 1.f / self.sendPackets * 100);
    
    // We can get IP address from pinger.hostAddress in here, but I am not do  it.
    
#ifdef DEBUG
    NSLog(@"seq:%ld,latency:%ld, packetloss:%f", self.sendPackets ,self.delay, self.packetLoss);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didReportSequence:self.sendPackets timeout:NO delay:self.delay packetLoss:self.packetLoss host:_hostAddress];
    });
    
}

- (void)simplePing:(LYTSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    [pinger stop];
}

#pragma mark - private methods

- (void)doPing
{
    [self clearSimplePing];
    
    if (_sendPackets >= _pingCount) {
        [self stopPing];
        if ([self.delegate respondsToSelector:@selector(didStopPingRequest)]) {
            [self.delegate didStopPingRequest];
        }
        return;
    }
    self.simplePing = [[LYTSimplePing alloc] initWithHostName:self.host];
    self.simplePing.delegate = self;
    [self.simplePing start];
    
    [self performSelector:@selector(pingTimeout) withObject:nil afterDelay:PING_afterDelay];
}

- (void)pingTimeout
{
    
#ifdef DEBUG
    NSLog(@"ping Timeout");
#endif
    
    [self clearSimplePing];
    
    self.delay = PING_TIMEOUT_DELAY;
    self.packetLoss = (double)((self.sendPackets - self.receivePackets) * 1.f / self.sendPackets * 100);
    
#ifdef DEBUG
    NSLog(@"seq:%ld,latency:%ld, packetloss:%f", self.sendPackets ,self.delay, self.packetLoss);
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didReportSequence:self.sendPackets timeout:YES delay:self.delay packetLoss:self.packetLoss host:_hostAddress];
    });
}

- (void)clearSimplePing
{
    if (self.simplePing) {
        [self.simplePing stop];
        self.simplePing.delegate = nil;
        self.simplePing = nil;
    }
}

/**
* 将ping接收的数据转换成ip地址
* @param address 接受的ping数据
*/
-(NSString *)DisplayAddressForAddress:(NSData *)address
{
    int err;
    NSString *result;
    char hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t)[address length], hostStr, sizeof(hostStr),
                          NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    
    return result;
}


@end
