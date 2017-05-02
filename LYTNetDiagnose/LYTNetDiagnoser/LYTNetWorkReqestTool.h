//
//  NetWorkReqestTool.h
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/23.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LYTNetInfo;
@interface LYTNetWorkReqestTool : NSObject
+ (instancetype)shareManager;
- (void)requestMyIPaddressSuccessBlock:(void (^)(LYTNetInfo * info))block;
@end
