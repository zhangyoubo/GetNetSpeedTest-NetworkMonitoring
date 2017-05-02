//
//  LYTSDKDataBase+LYTServersList.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/6.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTSDKDataBase+LYTServersList.h"
#import "LYTConfig.h"
@implementation LYTSDKDataBase (LYTServersList)
- (void)createChatdbServersList{
    [self.dbQueue inDatabase:^(LYTDatabase *db) {
        BOOL result = [db executeUpdate:@"create table if not exists server_list_table(\
                       id INTEGER PRIMARY KEY AUTOINCREMENT,\
                       Servers            text);"];
        NSAssert(result, @"createChatdbChatList Error");
    }];
}
- (void)dbInsertserver:(NSString *)server
                     succeed:(void (^)(BOOL result))block{
    
    if (server.length== 0) {
        return;
    }
    LYWeakSelf;
    dispatch_async(_concurrentQueue, ^{
        __block BOOL result = NO;
        [weakSelf.dbQueue inTransaction:^(LYTDatabase *db, BOOL *rollback) {
            result = [db executeUpdate:@"insert into server_list_table(Servers) values (?)",server];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(result);
            }
        });
        
    });
    
}
- (void)dbAllServersSucceed:(void (^)(NSArray <NSString *> *servers))block{
    LYWeakSelf
    __block NSMutableArray *array = @[].mutableCopy;
    dispatch_async(_concurrentQueue, ^{
        [weakSelf.dbQueue inDatabase:^(LYTDatabase *db) {
            
            LYTResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from server_list_table;"]];
            while (rs.next) {
                NSString *server = [rs stringForColumn:@"Servers"];
                if (server.length > 0) {
                  [array addObject:server];
                }
            }
            [rs close];
            // 回调
            dispatch_async(dispatch_get_main_queue(), ^{
                block(array);
            });
        }];
    });
}


@end
