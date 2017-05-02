//
//  LYTSDKDataBase+LYTServersList.h
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/6.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTSDKDataBase.h"

@interface LYTSDKDataBase (LYTServersList)
- (void)createChatdbServersList;

#pragma mark - add
/**
 插入新的列表 增加
 */
- (void)dbInsertserver:(NSString *)server
                     succeed:(void (^)(BOOL result))block;
#pragma mark - delete


#pragma mark - quary
- (void)dbAllServersSucceed:(void (^)(NSArray <NSString *> *servers))block;

@end
