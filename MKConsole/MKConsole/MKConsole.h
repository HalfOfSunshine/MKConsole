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

///如果需要直接输出系统的NSLog，将下面这段直接复制到PrefixHeader即可
// ===================>

//#import <MKConsole/MKConsole.h>

////只在Debug模式下执行NSLog
//#ifndef DEBUG
//#define NSLog(fmt, ...) MKLog((fmt),##__VA_ARGS__)
//#else
//......
//#endif

// <==================

NS_ASSUME_NONNULL_BEGIN

@interface MKConsole : NSObject
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic) BOOL enable;

void MKLog(NSString *format, ...);


/// UI开关，默认开启。  如通过宏替换了NSLog，关闭之后NSLog依然不会输出。
+(void)setEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END

// In this header, you should import all the public headers of your framework using statements like #import <MKConsole/PublicHeader.h>


