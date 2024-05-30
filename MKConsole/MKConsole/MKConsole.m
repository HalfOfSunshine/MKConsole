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
    NSString *oldText = self.textView.text;
    self.textView.text = [NSString stringWithFormat:@"%@%@\n",oldText,format];
    
    [self.textView setNeedsLayout];
    
    NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
    [self.textView scrollRangeToVisible:range];
}

- (UIWindow *)getFrontKeyWindow{
    if([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]&&[[[UIApplication sharedApplication] delegate] window]){
        return [[[UIApplication sharedApplication] delegate] window];
    }
    
    if (@available(iOS 13.0,*)) {
        NSArray *arr = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *windowScene =  (UIWindowScene *)arr[0];
        UIWindow *mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
        if(mainWindow) return mainWindow;
        return [UIApplication sharedApplication].windows.firstObject;
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
+(void)setEnable:(BOOL)enable{
    [[MKConsole shared] setEnable:enable];
}
+(BOOL)enable{
    return [[MKConsole shared] enable];
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
