//
//  LYTSDKDataBase.h
//  LeYingTong
//
//  Created by shangen on 17/2/6.
//  Copyright © 2017年 HHLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYTDB.h"

// 空值校验
#define nilReturn(obj,Block)  if (obj == nil) {\
                            block(Block);\
                            return;}

// 未登录校验回调 
#define unloginResult(rezult) \
if (!self.dbQueue) {\
!compelete ?: compelete(rezult);\
return;\
}

// 未登录 主线程回调
#define unloginBlock(rezult) \
if (!self.dbQueue) {\
dispatch_async(dispatch_get_main_queue(), ^{  \
!block ?: block(rezult);\
});\
return;\
}


@interface LYTSDKDataBase : NSObject
{
    dispatch_queue_t _concurrentQueue;
    dispatch_queue_t _serialQueue;

}
+ (instancetype)shareDatabase;
@property (nonatomic,strong) LYTDatabaseQueue *dbQueue;

/**
 创建数据库
 */
- (void)createSqlite;


/**
 关闭数据库 退出登录调用
 */
- (void)closeSqlite;

/**
 清理本地的数据库
 */
- (void)clearLoaclDatabase;

@end
