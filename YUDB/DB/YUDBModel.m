//
//  YUDBModel.m
//  YUDB
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//

#import "YUDBModel.h"
#import <objc/runtime.h>
#import "YUDBManager.h"

#define kDbText @"text"
#define kDbInteger @"integer"
#define kDbBlob @"blob"
#define kDbReal @"real"
#define kDbNull @"null"
#define kPrimaryKey @"primary key autoincrement"
#define kPK @"pk"

#define kName @"name"
#define kType @"type"

@interface YUDBModel()

// 属性名
@property(nonatomic, strong) NSMutableArray *propNames;
// 属性类型
@property(nonatomic, strong) NSMutableArray *propTypes;

@end

static NSDictionary *_allProps = nil;

@implementation YUDBModel

+ (void)initialize
{
    if (self != [YUDBModel self]) {
        [self createTable];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        //        NSDictionary *props = [self.class getPropertys];
        self.propNames = _allProps[kName];
        self.propTypes = _allProps[kType];
    }
    return self;
}

+ (NSArray *)findByFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *params = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self findByCondition:params];
}

+ (NSArray *)findByCondition:(NSString *)condition
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@", NSStringFromClass(self.class), condition];
    YUDBManager *mgr = [YUDBManager sharedManager];
    NSMutableArray *array = [NSMutableArray array];
    [mgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *results = [db executeQuery:sql];
        NSArray *propNames = _allProps[kName];
        NSArray *types = _allProps[kType];
        while ([results next]) {
            YUDBModel *model = [[self.class alloc] init];
            [model setValue:@([results intForColumn:kPK]) forKey:kPK];
            for (int i=0; i<propNames.count; i++) {
                NSString *name = propNames[i];
                NSString *type = types[i];
                [self setModelValue:model resultSet:results name:name forType:type];
            }
            [array addObject:model];
        }
    }];
    return array;
}

+ (BOOL)updateObjs:(NSArray *)objs
{
    if (objs == nil || objs.count == 0) {
        NSLog(@"对象数组不能为空");
        return NO;
    }
    __block BOOL result = YES;
    YUDBManager *dbMgr = [YUDBManager sharedManager];
    [dbMgr.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (YUDBModel *model in objs) {
            if (model.pk <= 0) {
                NSLog(@"%@没有指定对象唯一标识，更新失败", model);
                result = NO;
                *rollback = YES;
                return;
            }
            NSMutableString *columnStr = [NSMutableString string];
            NSMutableArray *values = [NSMutableArray array];
            NSArray *propNames = model.propNames;
            for (NSString *name in propNames) {
                [columnStr appendFormat:@"%@=?,", name];
                id value = [model valueForKey:name];
                if (value == nil) {
                    value = @"";
                }
                [values addObject:value];
            }
            [columnStr deleteCharactersInRange:NSMakeRange(columnStr.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where pk = %d", NSStringFromClass(model.class), columnStr, model.pk];
            BOOL success = [db executeUpdate:sql withArgumentsInArray:values];
            if (!success) {
                result = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return result;
}

- (BOOL)update
{
    if (self.pk <= 0) {
        NSLog(@"没有指定对象唯一标识, 更新失败");
        return NO;
    }
    NSMutableString *columnStr = [NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *name in _propNames) {
        [columnStr appendFormat:@"%@=?,", name];
        id value = [self valueForKey:name];
        if (value == nil) {
            value = @"";
        }
        [values addObject:value];
    }
    [columnStr deleteCharactersInRange:NSMakeRange(columnStr.length - 1, 1)];
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where pk = %d", NSStringFromClass(self.class), columnStr, self.pk];
    __block BOOL result = YES;
    YUDBManager *dbMgr = [YUDBManager sharedManager];
    [dbMgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql withArgumentsInArray:values];
    }];
    return result;
}

+ (BOOL)removeByCondition:(NSString *)condition
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@", NSStringFromClass(self.class), condition];
    __block BOOL result = YES;
    YUDBManager *dbMgr = [YUDBManager sharedManager];
    [dbMgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

+ (BOOL)removeObjs:(NSArray *)objs
{
    if (objs == nil || objs.count == 0) {
        NSLog(@"对象数组不能为空");
        return NO;
    }
    __block BOOL result = YES;
    YUDBManager *dbMgr = [YUDBManager sharedManager];
    [dbMgr.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (YUDBModel *model in objs) {
            if (model.pk <= 0) {
                NSLog(@"%@没有指定对象唯一标识，删除失败", model);
                result = NO;
                *rollback = YES;
                return;
            }
            NSString *sql = [NSString stringWithFormat:@"delete from %@ where pk = %d", NSStringFromClass(model.class), model.pk];
            BOOL success = [db executeUpdate:sql];
            if (!success) {
                result = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return result;
}

- (BOOL)remove
{
    if (self.pk <= 0) {
        NSLog(@"没有指定对象唯一标识，删除失败");
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where pk = %d", NSStringFromClass(self.class), self.pk];
    __block BOOL result = YES;
    YUDBManager *dbMgr = [YUDBManager sharedManager];
    [dbMgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql];
    }];
    return result;
}

+ (NSArray *)findAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@", NSStringFromClass(self.class)];
    YUDBManager *mgr = [YUDBManager sharedManager];
    NSMutableArray *array = [NSMutableArray array];
    [mgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *results = [db executeQuery:sql];
        NSArray *propNames = _allProps[kName];
        NSArray *types = _allProps[kType];
        while ([results next]) {
            YUDBModel *model = [[self.class alloc] init];
            [model setValue:@([results intForColumn:kPK]) forKey:kPK];
            for (int i=0; i<propNames.count; i++) {
                NSString *name = propNames[i];
                NSString *type = types[i];
                [self setModelValue:model resultSet:results name:name forType:type];
            }
            [array addObject:model];
        }
    }];
    return array;
}

+ (void)setModelValue:(YUDBModel *)model resultSet:(FMResultSet *)results name:(NSString *)name forType:(NSString *)type {
    if ([type isEqualToString:kDbText]) {
        [model setValue:[results stringForColumn:name] forKey:name];
    } else if ([type isEqualToString:kDbBlob]) {
        [model setValue:[results dataForColumn:name] forKey:name];
    } else if ([type isEqualToString:kDbInteger]) {
        [model setValue:[NSNumber numberWithLongLong:[results longLongIntForColumn:name]] forKey:name];
    } else if ([type isEqualToString:kDbReal]){
        [model setValue:[NSNumber numberWithDouble:[results doubleForColumn:name]] forKey:name];
    } else {
        [model setValue:@"" forKey:name];
    }
}

+ (BOOL)saveObjs:(NSArray *)objs
{
    if (objs == nil || objs.count == 0) {
        NSLog(@"对象数组不能为空");
        return NO;
    }
    YUDBManager *mgr = [YUDBManager sharedManager];
    __block BOOL result = YES;
    [mgr.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (YUDBModel *model in objs) {
            NSMutableString *keyStr = [NSMutableString string];
            NSMutableString *valueStr = [NSMutableString string];
            NSMutableArray *values = [NSMutableArray array];
            NSArray *propNames = model.propNames;
            for (int i=0; i<propNames.count; i++) {
                NSString *propName = propNames[i];
                [keyStr appendFormat:@"%@,", propName];
                [valueStr appendFormat:@"?,"];
                id value = [model valueForKey:propName];
                if (value == nil) {
                    value = @"";
                }
                [values addObject:value];
            }
            [keyStr deleteCharactersInRange:NSMakeRange(keyStr.length - 1, 1)];
            [valueStr deleteCharactersInRange:NSMakeRange(valueStr.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@);", NSStringFromClass(model.class), keyStr, valueStr];
            BOOL success = [db executeUpdate:sql withArgumentsInArray:values];
            if (!success) {
                result = NO;
                *rollback = YES;
                return;
            } else {
                model.pk = (int)[db lastInsertRowId];
            }
        }
    }];
    return result;
}

- (BOOL)save
{
    NSMutableString *keyStr = [NSMutableString string];
    NSMutableString *valueStr = [NSMutableString string];
    NSMutableArray *values = [NSMutableArray array];
    for (int i=0; i<_propNames.count; i++) {
        NSString *propName = _propNames[i];
        [keyStr appendFormat:@"%@,", propName];
        [valueStr appendFormat:@"?,"];
        id value = [self valueForKey:propName];
        if (value == nil) {
            value = @"";
        }
        [values addObject:value];
    }
    [keyStr deleteCharactersInRange:NSMakeRange(keyStr.length - 1, 1)];
    [valueStr deleteCharactersInRange:NSMakeRange(valueStr.length - 1, 1)];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@);", NSStringFromClass(self.class), keyStr, valueStr];
    YUDBManager *mgr = [YUDBManager sharedManager];
    __block BOOL result = YES;
    [mgr.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:sql withArgumentsInArray:values];
        if (!success) {
            result = NO;
        } else {
            _pk = (int)[db lastInsertRowId];
        }
    }];
    return result;
}

// 创建表
+ (BOOL)createTable {
    YUDBManager *mgr = [YUDBManager sharedManager];
    __block BOOL result = YES;
    [mgr.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [self getCreateTableSql];
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            result = NO;
            *rollback = YES;
            return;
        }
        NSString *tableName = NSStringFromClass(self.class);
        FMResultSet *columns = [db getTableSchema:tableName];
        NSMutableArray *columnNames = [NSMutableArray array];
        while ([columns next]) {
            NSString *columnName = [columns stringForColumn:@"name"];
            [columnNames addObject:columnName];
        }
        // 过滤出新增的字段
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"not (self in %@)", columnNames];
        NSDictionary *propertys = _allProps;
        NSArray *propertyNames = propertys[kName];
        NSArray *addArray = [propertyNames filteredArrayUsingPredicate:predicate];
        if (addArray == nil || addArray.count == 0) {
            return;
        }
        NSMutableString *columnStr = [NSMutableString string];
        for (NSString *name in addArray) {
            NSInteger index = [propertyNames indexOfObject:name];
            NSString *type = propertys[kType][index];
            [columnStr appendFormat:@"%@ %@,", name, type];
        }
        [columnStr deleteCharactersInRange:NSMakeRange(columnStr.length - 1, 1)];
        NSString *addColumnSql = [NSString stringWithFormat:@"alter table %@ add(%@);", tableName, columnStr];
        BOOL succ = [db executeUpdate:addColumnSql];
        if (!succ) {
            result = NO;
            *rollback = YES;
            return;
        }
    }];
    return result;
}
// 获取建表SQL语句
+ (NSString *)getCreateTableSql {
    NSMutableString *columnStr = [NSMutableString stringWithFormat:@"%@ integer %@,", kPK, kPrimaryKey];
    NSDictionary *props = [self getPropertys];
    _allProps = props;
    NSArray *names = props[kName];
    NSArray *types = props[kType];
    for (int i=0; i<names.count; i++) {
        [columnStr appendFormat:@"%@ %@,", names[i], types[i]];
    }
    [columnStr deleteCharactersInRange:NSMakeRange(columnStr.length - 1, 1)];
    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(%@);", NSStringFromClass(self.class), columnStr];
    return sql;
}

// 获取所有属性
+ (NSDictionary *)getPropertys {
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *types = [NSMutableArray array];
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList(self.class, &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = propertys[i];
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [names addObject:name];
        // 获取属性类型
        NSString *type = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        if ([type hasPrefix:@"T@\"NSString\""]) {
            [types addObject:kDbText];
        } else if ([type hasPrefix:@"T@\"NSData\""]) {
            [types addObject:kDbBlob];
        } else if ([type hasPrefix:@"Ti"] || [type hasPrefix:@"TI"] ||
                   [type hasPrefix:@"Ts"] || [type hasPrefix:@"TS"] ||
                   [type hasPrefix:@"Tq"] || [type hasPrefix:@"TQ"] ||
                   [type hasPrefix:@"TB"]) {
            [types addObject:kDbInteger];
        } else {
            [types addObject:kDbReal];
        }
    }
    free(propertys);
    return @{
             kName : names,
             kType : types
             };
}
@end

