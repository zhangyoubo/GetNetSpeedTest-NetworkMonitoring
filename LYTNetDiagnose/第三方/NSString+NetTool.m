//
//  NSString+NetTool.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/10.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "NSString+NetTool.h"
#import <arpa/inet.h>

@implementation NSString (NetTool)
- (BOOL)isIPaddress{
    
    in_addr_t addt =  inet_addr([self UTF8String]);
    in_addr_t addt255 = inet_addr("255.255.255.255");
    if (addt == addt255) {
        return NO;
    }else{
        return YES;
    }
}
@end
