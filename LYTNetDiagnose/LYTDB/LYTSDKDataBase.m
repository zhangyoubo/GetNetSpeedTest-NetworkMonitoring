//
//  LYTSDKDataBase.m
//  LeYingTong
//
//  Created by shangen on 17/2/6.
//  Copyright © 2017年 HHLY. All rights reserved.
//

#import "LYTSDKDataBase.h"
#import "LYTSDKDataBase+LYTServersList.h"
@implementation LYTSDKDataBase
static LYTSDKDataBase *dataBase = nil;
+ (instancetype)shareDatabase {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataBase = [[[LYTSDKDataBase class] alloc] init];
    });
    return dataBase;
}

- (instancetype)init {
    if (self = [super init]){
        _concurrentQueue = dispatch_queue_create("LYTSDKDataBase", DISPATCH_QUEUE_CONCURRENT);
        _serialQueue = dispatch_queue_create("LYTSDKDataBase", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString *)dbPath {
    NSString * document = @"/COM.HHLY.LYTSDK";
    NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:document];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbName = @"LYTNetDiagose.sqlite";
    return [documentPath stringByAppendingPathComponent:dbName] ;
}

- (void)createSqlite {
    [self closeSqlite];
    _dbQueue = [LYTDatabaseQueue databaseQueueWithPath:[self dbPath]];
    [self createChatdbServersList];

    
    NSLog(@"SDK_DB---%@",[self dbPath]);
}

- (void)closeSqlite {
    if (_dbQueue) {
        [_dbQueue close];
        _dbQueue = nil;
    }
}

- (void)dealloc{
    
}

- (void)clearLoaclDatabase{
  
    NSString *dbPathstr =  [self dbPath];
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:dbPathstr error:nil];
    NSLog(@"删除本地的数据库结果=%zd",result);
    if (result) {//重新创建新的数据库
        [self createSqlite];
    }
}

@end
