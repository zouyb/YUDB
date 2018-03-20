# YUDB
对fmdatabase的封装，一句话即可实现对数据库的增删改查，使用非常方便

使用方法：
1、安装YUDB
pod 'YUDB'

2、模型类继承YUDBModel，即可直接对模型对象进行数据库操作
如：
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

更多方法调用见YUDBModel.h文件，有详细注释
