//
//  MKConsole.h
//  MKConsole
//
//  Created by 麻明康 on 2024/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//! Project version number for MKConsole.
FOUNDATION_EXPORT double MKConsoleVersionNumber;

//! Project version string for MKConsole.
FOUNDATION_EXPORT const unsigned char MKConsoleVersionString[];


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConsole : NSObject

+ (id)shared;

/// 打印方法，使用同方式NSLog()
/// - Parameter format: 打印内容
void MKLog(NSString *format, ...);

/// 总开关，默认打开。
@property (nonatomic) BOOL logEnable;

/// 是否打印系统日志，默认打开
@property (nonatomic) BOOL printSystemLog;

/// 清空log内容
-(void)clean;
@end

NS_ASSUME_NONNULL_END

// In this header, you should import all the public headers of your framework using statements like #import <MKConsole/PublicHeader.h>


