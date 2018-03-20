# YUDB
对fmdatabase的封装，一句话即可实现对数据库的增删改查，使用非常方便

使用方法：<br/>
1、安装YUDB<br/>
pod 'YUDB'<br/>
<br/>
2、模型类继承YUDBModel，即可直接对模型对象进行数据库操作<br/>
如：<br/>
	YUUser *user = [[YUUser alloc] init];<br/>
    user.username = @"张三";<br/>
    user.age = 20;<br/>
    // 保存user对象到数据库<br/>
    BOOL succ = [user save];<br/>
    if (succ) {<br/>
        NSLog(@"保存成功");<br/>
    } else {<br/>
        NSLog(@"保存失败");<br/>
    }<br/>
    // 从数据库查询所有User对象<br/>
    NSArray *users = [YUUser findAll];<br/>
    for (YUUser *u in users) {<br/>
        NSLog(@"%@-%d", u.username, u.age);<br/>
    }<br/>

更多方法调用见YUDBModel.h文件，有详细注释<br/>
