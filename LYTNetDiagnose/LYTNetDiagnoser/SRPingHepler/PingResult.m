//
//  PingResult.m
//  SRPingHeplerTest
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 seewo. All rights reserved.
//

#import "PingResult.h"

@implementation PingResult

- (id)initWithTimeout:(BOOL)isTimeout sequence:(NSUInteger)seq delay:(NSUInteger)delay host:(NSString *)host
{
    if (self = [super init]) {
        if (isTimeout) {
            self.resultImage = [UIImage imageNamed:@"red"];
        } else {
            self.resultImage = [UIImage imageNamed:@"green"];
        }
        self.seq = seq;
        self.host = host;
        self.ttl = [NSString stringWithFormat:@"%ld ms", delay];
    }
    return self;
}

@end
