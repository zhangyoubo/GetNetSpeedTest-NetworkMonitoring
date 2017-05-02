//
//  LYTConfig.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/5.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTConfig.h"

#define title @"title"
#define desTitle @"desTitle"
#define imageName @"imageName"
#define className @"className"
@implementation LYTConfig
+ (NSArray *)mainViewArray{
    NSArray *array = @[
                              @{title:@"ping",
                                desTitle:@"利用“ping”命令可以检查网络是否连通，可以很好地帮助我们分析和判定网络故障",
                                imageName:@"",
                                className:@"LYTPingViewController"},
                              @{title:@"Traceroute",
                                desTitle:@"用来发出数据包的主机到目标主机之间所经过的网关的工具",
                                imageName:@"",
                                className:@"TracerouteViewController2",
                                },
                              @{title:@"DNS",
                                desTitle:@"因特网上作为域名和IP地址相互映射的一个分布式数据库，能够使用户更方便的访问互联网，而不用去记住能够被机器直接读取的IP数串。",
                                imageName:@"",
                                className:@"LYTDNSViewController"
                                },
                              @{title:@"端口检测",
                                desTitle:@"",
                                imageName:@"",
                                className:@"TYHPortScanController",
                                },
                              
                    ];
    return array;
}
@end
