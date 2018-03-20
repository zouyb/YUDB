//
//  YUDBManager.m
//  YUDB
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//

#import "YUDBManager.h"

static YUDBManager *_instance = nil;

@implementation YUDBManager

+ (id)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (FMDatabaseQueue *)dbQueue
{
    if (_dbQueue == nil) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    }
    return _dbQueue;
}

- (NSString *)dbPath
{
    if (!_dbPath) {
        NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *savePath = [docDir stringByAppendingPathComponent:@"db/model.sqlite"];
        _dbPath = savePath;
    }
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:_dbPath]) {
        NSString *dir = [_dbPath stringByDeletingLastPathComponent];
        [fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _dbPath;
}


@end
