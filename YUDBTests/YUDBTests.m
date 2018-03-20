//
//  YUDBTests.m
//  YUDBTests
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YUUser.h"

@interface YUDBTests : XCTestCase

@end

@implementation YUDBTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveUser {
    YUUser *user = [[YUUser alloc] init];
    user.username = @"张三";
    user.age = 20;
    // 保存user对象到数据库
    BOOL succ = [user save];
    if (succ) {
        NSLog(@"保存成功");
    } else {
        NSLog(@"保存失败");
    }
    // 从数据库查询所有User对象
    NSArray *users = [YUUser findAll];
    for (YUUser *u in users) {
        NSLog(@"%@-%d", u.username, u.age);
    }
}

@end
