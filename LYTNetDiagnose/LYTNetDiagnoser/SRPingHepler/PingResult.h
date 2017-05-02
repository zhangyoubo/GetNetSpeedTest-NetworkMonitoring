//
//  PingResult.h
//  SRPingHeplerTest
//
//  Created by guoqingwei on 16/6/1.
//  Copyright © 2016年 seewo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PingResult : NSObject

@property (nonatomic, strong) UIImage *resultImage;
@property (nonatomic) NSUInteger seq;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *ttl;


- (id)initWithTimeout:(BOOL)isTimeout sequence:(NSUInteger)seq delay:(NSUInteger)delay host:(NSString *)host;

@end
