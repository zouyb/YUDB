//
//  YUUser.h
//  YUDBTests
//
//  Created by zouyb on 2018/3/20.
//  Copyright © 2018年 zouyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YUDBModel.h"

@interface YUUser : YUDBModel

@property(nonatomic, strong) NSString *username;
@property(nonatomic, assign) int age;

@end
