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

如需替换系统的NSLog，在PrefixHeader内添加以下内容：
```
    //只在Debug模式下执行NSLog
    #ifndef DEBUG
    #define NSLog(fmt, ...) MKLog((fmt),##__VA_ARGS__)
    #else
    //.....你自己的逻辑
    #endif
```
