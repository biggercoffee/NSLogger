//
//  LoggerMainController.m
//  NSLogger
//
//  Created by admin on 2019/10/9.
//  Copyright © 2019 Florent Pillet. All rights reserved.
//

#import "LoggerMainController.h"
typedef void(^LoggerExecBlock)(void);
@interface LoggerMainController ()
@property (nonatomic,strong) NSMutableArray<LoggerExecBlock> *blocks;
@end

@implementation LoggerMainController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)(void))block {
    if (self.blocks == nil) {
        self.blocks = [NSMutableArray array];
    }
    NSButton *button = [NSButton buttonWithTitle:title target:self action:@selector(execBlock:)];
    button.tag = 1000+self.blocks.count;
    button.frame = CGRectMake(0, 0, 200, 40);
    [self.window.contentView addSubview:button];
    NSInteger rowCount = 4;
    if (self.blocks.count) {
        NSInteger rowY = self.blocks.count / rowCount;
        CGRect rect = button.frame;
        if (self.blocks.count % rowCount == 0) {
            rect.origin.x = 0;
        } else {
            NSButton *last = [self.window.contentView viewWithTag:1000+self.blocks.count-1];
            rect.origin.x = CGRectGetMaxX(last.frame);
        }
        rect.origin.y = rowY * 40;
        button.frame = rect;
    }
    [self.blocks addObject:block];
}

- (void)execBlock:(NSButton *)button {
    NSInteger tag = button.tag - 1000;
    LoggerExecBlock block = self.blocks[tag];
    block();
}
- (IBAction)clearAction:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    alert.messageText = @"谁最帅?";
    alert.informativeText = @"我最帅.";
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            for (NSInteger i = 0; i < self.blocks.count; i++) {
                NSView *view = [self.window.contentView viewWithTag:1000+i];
                [view removeFromSuperview];
            }
            [self.blocks removeAllObjects];
        }
    }];
}

@end
