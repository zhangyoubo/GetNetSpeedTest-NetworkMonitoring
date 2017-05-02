//
//  LYTDetecteInfo.h
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYTPingInfo : NSObject

/**
 经历的时间
 */
@property (assign, nonatomic) float durationTime;

/**
 消息序号
 */
@property (copy, nonatomic) NSString *sequence;

/**
  消息标示
 */
@property (copy, nonatomic) NSString *identifier;


/**
 携带的信息
 */
@property (copy, nonatomic) NSString *infoStr;

/**
 存储数组 
 */
@property (nonatomic,strong) NSArray *infoArray;
@end
