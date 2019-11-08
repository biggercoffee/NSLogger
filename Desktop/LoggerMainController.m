//
//  LoggerMainController.m
//  NSLogger
//
//  Created by admin on 2019/10/9.
//  Copyright © 2019 Florent Pillet. All rights reserved.
//

#import "LoggerMainController.h"
#import "Masonry.h"
#import "LoggerConnection.h"
#import "LoggerDocument.h"
typedef void(^LoggerExecBlock)(void);
@interface LoggerMainController () <NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSTextField *searchTextField;
@property (weak) IBOutlet NSTableView *tableview;
@property (weak) IBOutlet NSButton *clearButton;
@property (nonatomic,strong) NSMutableArray<LoggerConnection *> *dataSource;
@property (nonatomic,strong) NSMutableArray<LoggerConnection *> *tempDataSource;
@end

@implementation LoggerMainController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

- (void)addData:(LoggerConnection *)data {
    [self.dataSource addObject:data];
    [self.tableview reloadData];
}

- (IBAction)searchAction:(id)sender {
    NSString *text = self.searchTextField.stringValue;
    if (text.length == 0) {
        [self.dataSource addObjectsFromArray:self.tempDataSource];
        [self.tableview reloadData];
        [self.tempDataSource removeAllObjects];
        return ;
    }
    if (self.tempDataSource.count == 0) {
        [self.tempDataSource addObjectsFromArray:self.dataSource];
    }
    [self.dataSource removeAllObjects];
    NSArray<LoggerConnection *> *filterData = [self.tempDataSource filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LoggerConnection *obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [[obj.clientName uppercaseString] containsString:[text uppercaseString]];
    }]];
    [self.dataSource addObjectsFromArray:filterData];
    [self.tableview reloadData];
}

- (IBAction)cleanDisconnect:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    alert.messageText = @"谁最帅?";
    alert.informativeText = @"我最帅.";

    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            if (self.tempDataSource.count > 0) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:self.tempDataSource];
            }
                 
            NSArray<LoggerConnection *> *newData = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LoggerConnection  *x, NSDictionary<NSString *,id> * _Nullable bindings) {
                return x.connected;
            }]];
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:newData];
            [self.tableview reloadData];
        }
    }];
    
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
            [self.tempDataSource removeAllObjects];
            [self.dataSource removeAllObjects];
            [self.tableview reloadData];
        }
    }];
}

#pragma mark - tableview

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *strIdt = @"123";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:strIdt owner:self];
    if (!cell) {
        cell = [[NSTableCellView alloc]init];
        cell.identifier = strIdt;
    }
    NSButton *button = [cell viewWithTag:1000];
    if (button == nil) {
        button = [NSButton new];
        [button setTag:1000];
        [cell addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.offset(0);
        }];
        [button setTarget:self];
        [button setAction:@selector(cellButtonAction:)];
    }
    LoggerConnection *data = self.dataSource[row];
    NSString *text = [NSString stringWithFormat:@"%zi-%@(%@)",row,data.clientName,data.clientOSVersion];
    if (data.connected == NO) {
        text = [text stringByAppendingString:@"(断开链接)"];
    }
    [button setTitle:text];
    return cell;
    
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 60;
}

- (void)cellButtonAction:(NSButton *)button {
    NSArray<NSString *> *strings = [button.title componentsSeparatedByString:@"-"];
    if (strings.count == 0) {
        return ;
    }
    NSInteger row = strings.firstObject.integerValue;

    LoggerConnection *aConnection = self.dataSource[row];
    NSDocumentController *docController = [NSDocumentController sharedDocumentController];
    for (LoggerDocument *doc in [docController documents])
    {
        if (![doc isKindOfClass:[LoggerDocument class]])
            continue;
        for (LoggerConnection *c in doc.attachedLogs)
        {
            if (c != aConnection && [aConnection isNewRunOfClient:c])
            {
                // recycle this document window, bring it to front
                aConnection.reconnectionCount = ((LoggerConnection *)[doc.attachedLogs lastObject]).reconnectionCount + 1;
                [doc addConnection:aConnection];
                return;
            }
        }
    }
    
    // Instantiate a new window for this connection
    LoggerDocument *doc = [[LoggerDocument alloc] initWithConnection:aConnection];
    [docController addDocument:doc];
    [doc makeWindowControllers];
    [doc showWindows];
}

- (NSMutableArray<LoggerConnection *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray<LoggerConnection *> alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray<LoggerConnection *> *)tempDataSource {
    if (!_tempDataSource) {
        _tempDataSource = [[NSMutableArray<LoggerConnection *> alloc] init];
    }
    return _tempDataSource;
}
@end
