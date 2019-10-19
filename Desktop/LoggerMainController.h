//
//  LoggerMainController.h
//  NSLogger
//
//  Created by admin on 2019/10/9.
//  Copyright © 2019 Florent Pillet. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoggerMainController : NSWindowController
- (void)addButtonWithTitle:(NSString *)title block:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
