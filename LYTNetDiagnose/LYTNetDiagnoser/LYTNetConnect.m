//
//  LDNetConnect.m
//  LDNetDiagnoServiceDemo
//
//  Created by ZhangHaiyang on 15-8-5.
//  Copyright (c) 2015年 庞辉. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>

#import "LYTNetConnect.h"
#import "LYTNetTimer.h"

static int timeOut = 3;
@interface LYTNetConnect () {
    BOOL _isExistSuccess;  //监测是否有connect成功
    NSInteger _connectCount;     //当前执行次数

    NSInteger tcpPort;             //执行端口
    NSString *_hostAddress;  //目标域名的IP地址
    BOOL _isIPV6;
    NSString *_resultLog;
    NSInteger _sumTime;
    CFSocketRef _socket;
    NSInteger MAXCOUNT_CONNECT;
    
}

@property (nonatomic, assign) long _startTime;  //每次执行的开始时间

@end

@implementation LYTNetConnect
@synthesize _startTime;

/**
 * 停止connect
 */
- (void)stopConnect
{
    _connectCount = MAXCOUNT_CONNECT + 1;
}

/**
 * 通过hostaddress和port 进行connect诊断
 */
- (void)runWithHostAddress:(NSString *)hostAddress port:(NSInteger)port maxTestCount:(NSInteger)testCount;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _hostAddress = hostAddress;
        MAXCOUNT_CONNECT = testCount;
        _isIPV6 = [_hostAddress rangeOfString:@":"].location == NSNotFound?NO:YES;
        tcpPort = port;
        _isExistSuccess = FALSE;
        _connectCount = 0;
        _sumTime = 0;
        _resultLog = @"";
        if (self.delegate && [self.delegate respondsToSelector:@selector(appendSocketLog:)]) {
            [self.delegate
             appendSocketLog:[NSString stringWithFormat:@"connect to host %@ ...", _hostAddress]];
        }
        _startTime = [LYTNetTimer getMicroSeconds];
        [self connect];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (_connectCount < MAXCOUNT_CONNECT);

    });
}

/**
 * 建立socket对hostaddress进行连接
 */
- (void)connect
{
    NSData *addrData = nil;
    
    //设置地址
    if (!_isIPV6) {
        struct sockaddr_in nativeAddr4;
        memset(&nativeAddr4, 0, sizeof(nativeAddr4));
        nativeAddr4.sin_len = sizeof(nativeAddr4);
        nativeAddr4.sin_family = AF_INET;
        nativeAddr4.sin_port = htons(tcpPort);
        inet_pton(AF_INET, _hostAddress.UTF8String, &nativeAddr4.sin_addr.s_addr);
        addrData = [NSData dataWithBytes:&nativeAddr4 length:sizeof(nativeAddr4)];
    } else {
        struct sockaddr_in6 nativeAddr6;
        memset(&nativeAddr6, 0, sizeof(nativeAddr6));
        nativeAddr6.sin6_len = sizeof(nativeAddr6);
        nativeAddr6.sin6_family = AF_INET6;
        nativeAddr6.sin6_port = htons(tcpPort);
        inet_pton(AF_INET6, _hostAddress.UTF8String, &nativeAddr6.sin6_addr);
        addrData = [NSData dataWithBytes:&nativeAddr6 length:sizeof(nativeAddr6)];
    }
    
    if (addrData != nil) {
        [self connectWithAddress:addrData];
    }
}

-(void)connectWithAddress:(NSData *)addr{
    struct sockaddr *pSockAddr = (struct sockaddr *)[addr bytes];
    int addressFamily = pSockAddr->sa_family;
    
    //创建套接字
    CFSocketContext CTX = {0, (__bridge_retained void *)(self), NULL, NULL, NULL};
    _socket = CFSocketCreate(kCFAllocatorDefault, addressFamily, SOCK_STREAM, IPPROTO_TCP,
                             kCFSocketConnectCallBack, TCPServerConnectCallBack, &CTX);
    
    //执行连接
    CFSocketConnectToAddress(_socket, (__bridge CFDataRef)addr, timeOut);
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();  // 获取当前运行循环
    CFRunLoopSourceRef source =
    CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, _connectCount);  //定义循环对象
    CFRunLoopAddSource(cfrl, source, kCFRunLoopDefaultMode);  //将循环对象加入当前循环中
    CFRelease(source);
    
}


/**
 * connect回调函数
 */
static void TCPServerConnectCallBack(CFSocketRef socket, CFSocketCallBackType type,
                                     CFDataRef address, const void *data, void *info)
{
    NSLog(@"TCPServerConnectCallBack - data = %zd",sizeof(data));
    if (data != NULL) {
        NSLog(@"连接失败");
        LYTNetConnect *con = (__bridge_transfer LYTNetConnect *)info;
        [con readStream:FALSE];
    } else {

        LYTNetConnect *con = (__bridge_transfer LYTNetConnect *)info;
        [con readStream:TRUE];
    }
}

/**
 * 返回之后的一系列操作
 */
- (void)readStream:(BOOL)success
{
    //    NSString *errorLog = @"";
    if (success) {
        _isExistSuccess = TRUE;
        NSInteger interval = [LYTNetTimer computeDurationSince:_startTime] / 1000;
        _sumTime += interval;
        _resultLog = [_resultLog
            stringByAppendingString:[NSString stringWithFormat:@"host:%@% zd's time=%ldms, \n",_hostAddress,
                                                               _connectCount + 1, (long)interval]];
    } else {
        _sumTime = 99999;
        _resultLog =
            [_resultLog stringByAppendingString:[NSString stringWithFormat:@"host:%@ %zd's time=TimeOut, \n",_hostAddress,
                                                                           _connectCount + 1]];
    }
    if (_connectCount == MAXCOUNT_CONNECT - 1) {
        if (_sumTime >= 99999) {
            _resultLog = [_resultLog substringToIndex:[_resultLog length] - 1];
        } else {
            _resultLog = [_resultLog
                stringByAppendingString:[NSString stringWithFormat:@"average=%ldms",
                                                                   (long)(_sumTime / 4)]];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(appendSocketLog:)]) {
            [self.delegate appendSocketLog:_resultLog];
        }
    }

    CFRelease(_socket);
    _connectCount++;
    if (_connectCount < MAXCOUNT_CONNECT) {
        _startTime = [LYTNetTimer getMicroSeconds];
        [self connect];

    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(connectDidEnd:)]) {
            [self.delegate connectDidEnd:_isExistSuccess];
        }
    }
}

@end
