
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DCLoggerMaker;
/// 日志管理器
@interface DCLogger : NSObject
///日志输出的配置信息
///@code
///log(^());里面回调的是一个block，block里拿到make，然后进行一系列的参数设置即可
///@endcode
@property (nonatomic,copy,readonly,class) void(^log)(void(^)(DCLoggerMaker * const make));

@end

@interface DCLoggerMaker : NSObject
///标签
@property (nonatomic,copy,readonly) DCLoggerMaker *(^tag)(NSString *tag);
///输出的日志信息
@property (nonatomic,copy,readonly) DCLoggerMaker *(^logText)(NSString *logText);
///等级
@property (nonatomic,copy,readonly) DCLoggerMaker *(^level)(int level);
@end

NS_ASSUME_NONNULL_END
