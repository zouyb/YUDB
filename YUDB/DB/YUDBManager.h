//
//  YUDBManager.h
//  YUDB
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//  数据库管理类

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface YUDBManager : NSObject

@property(nonatomic, strong) FMDatabaseQueue *dbQueue;
// 数据库保存路径
@property(nonatomic, strong) NSString *dbPath;
// 获取数据库单例
+ (id)sharedManager;

@end
