//
//  LoggerMainController.h
//  NSLogger
//
//  Created by admin on 2019/10/9.
//  Copyright © 2019 Florent Pillet. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoggerConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoggerMainController : NSWindowController
- (void)addData:(LoggerConnection *)data;
@end

NS_ASSUME_NONNULL_END
