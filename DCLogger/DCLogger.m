

#import "DCLogger.h"
#import <objc/runtime.h>

#ifdef DEBUG
#import <NSLogger/NSLogger.h>
#define dc_logger($tag,$level,...)         LogMessageF(__FILE__, __LINE__, __FUNCTION__, $tag, $level, __VA_ARGS__)
#else
#define dc_logger(...)
#endif

@implementation UIViewController (DCLogger_newIMP)

- (void)dcLogger_viewWillAppear:(BOOL)animated {
    [self dcLogger_viewWillAppear:animated];
    dc_logger(@"viewWillAppear",100,@"当前controller:%@, title:%@",NSStringFromClass(self.class),self.navigationItem.title?:@"缺省值");
}

@end

@implementation UIControl (DCLogger_newIMP)

- (void)dcLogger_sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event {
    [self dcLogger_sendAction:action to:target forEvent:event];
    dc_logger(@"UIControl",200,@"当前指针:%@,"
              "\n target:%@,\n"
              " action:%@",self,target,NSStringFromSelector(action));
}

@end

void dclogger_method_exchangeImplementations(Class class,SEL originalSelector,SEL swizzledSelector) {

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
        class_addMethod(class,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
            swizzledSelector,
            method_getImplementation(originalMethod),
            method_getTypeEncoding(originalMethod));
        return ;
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@interface DCLoggerMaker ()
@property (nonatomic,copy  ) NSString *tagValue;
@property (nonatomic,assign) int      levelValue;
@property (nonatomic,copy  ) NSString *logTextValue;
@end

@implementation DCLogger

#ifdef DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //---- 埋点 -----
        dclogger_method_exchangeImplementations(
                                                UIViewController.class,
                                                @selector(viewWillAppear:),
                                                @selector(dcLogger_viewWillAppear:)
                                                );
        
        dclogger_method_exchangeImplementations(
                                                UIControl.class,
                                                @selector(sendAction:to:forEvent:),
                                                @selector(dcLogger_sendAction:to:forEvent:)
                                                );
        
        [UIDevice mj_setupIgnoredPropertyNames:^NSArray *{
            return @[@"generatesDeviceOrientationNotifications"];
        }];
        dc_logger(@"device",1000,@"设备信息:%@",[UIDevice.currentDevice mj_JSONString]);
        [UIDevice mj_setupIgnoredPropertyNames:^NSArray *{
            return @[];
        }];
    });
}
#endif

+ (void (^)(void (^ _Nonnull)(DCLoggerMaker * _Nonnull)))log {
    return ^(void(^x)(DCLoggerMaker *make)){
        if (x == nil) {
            return ;
        }
        DCLoggerMaker *maker = DCLoggerMaker.new;
        x(maker);
        dc_logger(maker.tagValue,maker.levelValue,@"%@", maker.logTextValue);
        x = nil;
    };
}

@end

@implementation DCLoggerMaker

- (DCLoggerMaker * _Nonnull (^)(NSString * _Nonnull))tag {
    return ^(NSString *tag) {
        return (void)({self.tagValue=tag;}),self;
    };
}

- (DCLoggerMaker * _Nonnull (^)(int))level {
    return ^(int level) {
        return (void)({self.levelValue=level;}),self;
    };
}

- (DCLoggerMaker * _Nonnull (^)(NSString * _Nonnull))logText {
    return ^(NSString *text) {
        return (void)({self.logTextValue=text;}),self;;
    };
}

@end
