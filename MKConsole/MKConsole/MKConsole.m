//
//  MKConsole.m
//  DSPDemo
//
//  Created by 麻明康 on 2024/2/20.
//

#import "MKConsole.h"
@interface MKConsole()
@property (nonatomic, weak) UIWindow *keyWindow;
@property (nonatomic, strong) UIButton *cleanBtn;
@property (nonatomic, strong) UIButton *foldBtn;
@property (nonatomic, assign) int originalFD;
@property (nonatomic, strong) NSFileHandle *pipeReadHandle;
@end

@implementation MKConsole
+ (id)shared{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enable = YES;
    }
    return self;
}

#pragma mark =============== Core Function ===============
void MKLog(NSString *format, ...){
    if (![[MKConsole shared] enable]) return;
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    [[MKConsole shared] log:formattedString];
}

-(void)log:(NSString *)format{
    if (![self.keyWindow.subviews containsObject:self.textView]) {
        [self addAllSubViews];
    }
    [self bringAllSubviewToFront];
    
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text,format];
    [self.textView setNeedsLayout];
    NSRange range = NSMakeRange(self.textView.text.length - 1, 0);
    [self.textView scrollRangeToVisible:range];
}

#pragma mark =============== systemLog ===============
- (void)redirectNotificationHandle:(NSNotification *)nf{ // 通知方法
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     
    [self log:str];
    [[nf object] readInBackgroundAndNotify];
}
 
- (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe] ;// 初始化一个NSPipe 对象
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    // 保存原始文件描述符
    int originalFD = dup(fd);
    
    // 重定向文件描述符
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
     
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle]; // 注册通知
    [pipeReadHandle readInBackgroundAndNotify];
    
    // 存储原始文件描述符以便以后恢复
    self.originalFD = originalFD;
    self.pipeReadHandle = pipeReadHandle;
}

#pragma mark =============== UI Operation ===============
- (UIWindow *)getFrontKeyWindow{
    if([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]&&[[[UIApplication sharedApplication] delegate] window]){
        return [[[UIApplication sharedApplication] delegate] window];
    }
    
    if (@available(iOS 13.0,*)) {
        if ([[[UIApplication sharedApplication] connectedScenes] allObjects].count>0) {
            NSArray *arr = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *windowScene =  (UIWindowScene *)arr[0];
            UIWindow *mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
            if(mainWindow) return mainWindow;
            return [UIApplication sharedApplication].windows.firstObject;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}


-(void)clean{
    self.textView.text = @"";
}

-(void)fold:(UIButton*)foldBtn{
    foldBtn.selected = !foldBtn.selected;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows[0].safeAreaInsets;
        CGFloat safeAreaHeight = (safeAreaInsets.bottom != 0)?safeAreaInsets.bottom:0;
        if (foldBtn.selected) {
            weakSelf.textView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width,0);
            weakSelf.foldBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-110, [UIScreen mainScreen].bounds.size.height-safeAreaHeight-20, 40, 20);
            weakSelf.cleanBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height-safeAreaHeight-20, 40, 20);
        }else{
            weakSelf.textView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-105, [UIScreen mainScreen].bounds.size.width,100);
            weakSelf.foldBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-110, [UIScreen mainScreen].bounds.size.height-105-20, 40, 20);
            weakSelf.cleanBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height-105-20, 40, 20);
        }
    }];
}

-(void)addAllSubViews{
    [self.keyWindow addSubview:self.textView];
    [self.keyWindow addSubview:self.cleanBtn];
    [self.keyWindow addSubview:self.foldBtn];
}

-(void)bringAllSubviewToFront{
    [self.keyWindow addSubview:_textView];
    [self.keyWindow addSubview:_cleanBtn];
    [self.keyWindow addSubview:_foldBtn];
}


#pragma mark =============== getter&setter ===============
- (void)setPrintSystemLog:(BOOL)printSystemLog{
    if (printSystemLog) {
        [self redirectSTD:STDOUT_FILENO];
        [self redirectSTD:STDERR_FILENO];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        // 恢复原始文件描述符
        dup2(self.originalFD, STDOUT_FILENO);
        close(self.originalFD);
        
        self.originalFD = -1;
        self.pipeReadHandle = nil;
    }
}
- (void)setEnable:(BOOL)enable{
    _enable = enable;
    if (!_enable) {
        [_textView removeFromSuperview];
        _textView = nil;
        
        [_cleanBtn removeFromSuperview];
        _cleanBtn = nil;
        
        [_foldBtn removeFromSuperview];
        _foldBtn = nil;
    }else{
        [self addAllSubViews];
    }
}


- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-105, [UIScreen mainScreen].bounds.size.width,100) textContainer:nil];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor brownColor];
        _textView.editable = NO;
        _textView.scrollEnabled = YES;
    }
    return _textView;
}

- (UIWindow *)keyWindow{
    if (!_keyWindow) {
        _keyWindow = [self getFrontKeyWindow];
    }
    return _keyWindow;
}

- (UIButton *)cleanBtn{
    if (!_cleanBtn) {
        _cleanBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height-105-20, 40, 20)];
        [_cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
        [_cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cleanBtn.titleLabel.font = [UIFont systemFontOfSize:12.];
        _cleanBtn.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        _cleanBtn.layer.cornerRadius = 5.;
        _cleanBtn.layer.borderColor = [[UIColor blackColor] CGColor];
        _cleanBtn.layer.borderWidth = 0.5f;
        [_cleanBtn addTarget:self action:@selector(clean) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanBtn;
}

- (UIButton *)foldBtn{
    if (!_foldBtn) {
        _foldBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-110, [UIScreen mainScreen].bounds.size.height-105-20, 40, 20)];
        [_foldBtn setTitle:@"收起" forState:UIControlStateNormal];
        [_foldBtn setTitle:@"展开" forState:UIControlStateSelected];
        [_foldBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _foldBtn.titleLabel.font = [UIFont systemFontOfSize:12.];
        _foldBtn.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        _foldBtn.layer.cornerRadius = 5.;
        _foldBtn.layer.borderColor = [[UIColor blackColor] CGColor];
        _foldBtn.layer.borderWidth = 0.5f;
        [_foldBtn addTarget:self action:@selector(fold:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _foldBtn;
}
@end
