//
//  LYTDatabaseQueue.m
//  LYTdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import "LYTDatabaseQueue.h"
#import "LYTDatabase.h"

#if LYTDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

/*
 
 Note: we call [self retain]; before using dispatch_sync, just incase 
 LYTDatabaseQueue is released on another thread and we're in the middle of doing
 something in dispatch_sync
 
 */

/*
 * A key used to associate the LYTDatabaseQueue object with the dispatch_queue_t it uses.
 * This in turn is used for deadlock detection by seeing if inDatabase: is called on
 * the queue's dispatch queue, which should not happen and causes a deadlock.
 */
static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;
 
@implementation LYTDatabaseQueue

@synthesize path = _path;
@synthesize openFlags = _openFlags;

+ (instancetype)databaseQueueWithPath:(NSString*)aPath {
    
    LYTDatabaseQueue *q = [[self alloc] initWithPath:aPath];
    
    LYTDBAutorelease(q);
    
    return q;
}

+ (instancetype)databaseQueueWithPath:(NSString*)aPath flags:(int)openFlags {
    
    LYTDatabaseQueue *q = [[self alloc] initWithPath:aPath flags:openFlags];
    
    LYTDBAutorelease(q);
    
    return q;
}

+ (Class)databaseClass {
    return [LYTDatabase class];
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags vfs:(NSString *)vfsName {
    
    self = [super init];
    
    if (self != nil) {
        
        _db = [[[self class] databaseClass] databaseWithPath:aPath];
        LYTDBRetain(_db);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:openFlags vfs:vfsName];
#else
        BOOL success = [_db open];
#endif
        if (!success) {
            DBLog(@"Could not create database queue for path %@", aPath);
            LYTDBRelease(self);
            return 0x00;
        }
        
        _path = LYTDBReturnRetained(aPath);
        
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"LYTdb.%@", self] UTF8String], NULL);
        dispatch_queue_set_specific(_queue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
        _openFlags = openFlags;
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags {
    return [self initWithPath:aPath flags:openFlags vfs:nil];
}

- (instancetype)initWithPath:(NSString*)aPath {
    
    // default flags for sqlite3_open
    return [self initWithPath:aPath flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE vfs:nil];
}

- (instancetype)init {
    return [self initWithPath:nil];
}

    
- (void)dealloc {
    
    LYTDBRelease(_db);
    LYTDBRelease(_path);
    
    if (_queue) {
        LYTDBDispatchQueueRelease(_queue);
        _queue = 0x00;
    }
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)close {
    LYTDBRetain(self);
    dispatch_sync(_queue, ^() {
        [self->_db close];
        LYTDBRelease(_db);
        self->_db = 0x00;
    });
    LYTDBRelease(self);
}

- (LYTDatabase*)database {
    if (!_db) {
        _db = LYTDBReturnRetained([LYTDatabase databaseWithPath:_path]);
        
#if SQLITE_VERSION_NUMBER >= 3005000
        BOOL success = [_db openWithFlags:_openFlags];
#else
        BOOL success = [_db open];
#endif
        if (!success) {
            DBLog(@"LYTDatabaseQueue could not reopen database for path %@", _path);
            LYTDBRelease(_db);
            _db  = 0x00;
            return 0x00;
        }
    }
    
    return _db;
}

- (void)inDatabase:(void (^)(LYTDatabase *db))block {
    /* Get the currently executing queue (which should probably be nil, but in theory could be another DB queue
     * and then check it against self to make sure we're not about to deadlock. */
    LYTDatabaseQueue *currentSyncQueue = (__bridge id)dispatch_get_specific(kDispatchQueueSpecificKey);
    assert(currentSyncQueue != self && "inDatabase: was called reentrantly on the same queue, which would lead to a deadlock");
    
    LYTDBRetain(self);
    
    dispatch_sync(_queue, ^() {
        
        LYTDatabase *db = [self database];
        block(db);
        
        if ([db hasOpenResultSets]) {
            DBLog(@"Warning: there is at least one open result set around after performing [LYTDatabaseQueue inDatabase:]");
            
#if defined(DEBUG) && DEBUG
            NSSet *openSetCopy = LYTDBReturnAutoreleased([[db valueForKey:@"_openResultSets"] copy]);
            for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
                LYTResultSet *rs = (LYTResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
                DBLog(@"query: '%@'", [rs query]);
            }
#endif
        }
    });
    
    LYTDBRelease(self);
}


- (void)beginTransaction:(BOOL)useDeferred withBlock:(void (^)(LYTDatabase *db, BOOL *rollback))block {
    LYTDBRetain(self);
    dispatch_sync(_queue, ^() { 
        
        BOOL shouldRollback = NO;
        
        if (useDeferred) {
            [[self database] beginDeferredTransaction];
        }
        else {
            [[self database] beginTransaction];
        }
        
        block([self database], &shouldRollback);
        
        if (shouldRollback) {
            [[self database] rollback];
        }
        else {
            [[self database] commit];
        }
    });
    
    LYTDBRelease(self);
}

- (void)inDeferredTransaction:(void (^)(LYTDatabase *db, BOOL *rollback))block {
    [self beginTransaction:YES withBlock:block];
}

- (void)inTransaction:(void (^)(LYTDatabase *db, BOOL *rollback))block {
    [self beginTransaction:NO withBlock:block];
}

- (NSError*)inSavePoint:(void (^)(LYTDatabase *db, BOOL *rollback))block {
#if SQLITE_VERSION_NUMBER >= 3007000
    static unsigned long savePointIdx = 0;
    __block NSError *err = 0x00;
    LYTDBRetain(self);
    dispatch_sync(_queue, ^() { 
        
        NSString *name = [NSString stringWithFormat:@"savePoint%ld", savePointIdx++];
        
        BOOL shouldRollback = NO;
        
        if ([[self database] startSavePointWithName:name error:&err]) {
            
            block([self database], &shouldRollback);
            
            if (shouldRollback) {
                // We need to rollback and release this savepoint to remove it
                [[self database] rollbackToSavePointWithName:name error:&err];
            }
            [[self database] releaseSavePointWithName:name error:&err];
            
        }
    });
    LYTDBRelease(self);
    return err;
#else
    NSString *errorMessage = NSLocalizedString(@"Save point functions require SQLite 3.7", nil);
    if (self.logsErrors) DBLog(@"%@", errorMessage);
    return [NSError errorWithDomain:@"LYTDatabase" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
#endif
}

@end
