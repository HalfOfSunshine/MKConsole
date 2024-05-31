# MKConsole
在app内打印输出的小插件
## 安装
    pod 'MKConsole'
## 使用
引入头文件
```
    #import <MKConsole/MKConsole.h>
```
在手机上打印输出日志
```
    NSString *name = @"MKLog";
    MKLog(@"这个是%@",name);
```

开启系统打印日志：
```
    [[MKConsole shared] setPrintSystemLog:YES];
```
