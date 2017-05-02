//
//  LYTDetecteInfo.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTPingInfo.h"

@implementation LYTPingInfo
- (NSString *)description
{
    return [NSString stringWithFormat:@"\n时间：%.2f ms\n信息：%@\n数组信息:%@\n消息序号：%@\n消息的标示：%@\n",self.durationTime,self.infoStr,self.infoArray,self.sequence,self.identifier];
}

@end
