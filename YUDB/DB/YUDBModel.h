//
//  YUDBModel.h
//  YUDB
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//  数据库模型对象封装，继承此类，即可直接对对象进行数据库操作

#import <Foundation/Foundation.h>

@interface YUDBModel : NSObject

// 主键
@property(nonatomic, assign) int pk;

/**
 保存对象到数据库
 
 @return 是否保存成功
 */
- (BOOL)save;

/**
 保存对象数组
 
 @param objs 对象数组
 @return 是否保存成功
 */
+ (BOOL)saveObjs:(NSArray *)objs;

/**
 删除对象
 
 @return 是否删除成功
 */
- (BOOL)remove;

/**
 删除对象数组
 
 @param objs 对象数组
 @return 是否删除成功
 */
+ (BOOL)removeObjs:(NSArray *)objs;

/**
 通过条件删除对象
 
 @param condition 条件 如：age=50
 @return 是否删除成功
 */
+ (BOOL)removeByCondition:(NSString *)condition;

/**
 更新对象
 
 @return 是否更新成功
 */
- (BOOL)update;

/**
 更新对象数组
 
 @param objs 对象数组
 @return 是否更新成功
 */
+ (BOOL)updateObjs:(NSArray *)objs;

// 查询表中所有数据
+ (NSArray *)findAll;
// 通过条件查询数据，如: name=张三
+ (NSArray *)findByCondition:(NSString *)condition;
// 动态参数查找
+ (NSArray *)findByFormat:(NSString *)format, ...;

@end
