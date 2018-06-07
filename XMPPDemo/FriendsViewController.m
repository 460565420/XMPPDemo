//
//  FriendsViewController.m
//  XMPPDemo
//
//  Created by xieqilin on 2018/6/7.
//  Copyright © 2018年 xieqilin. All rights reserved.
//

#import "FriendsViewController.h"
#import "SDAutoLayout.h"

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FriendsViewController

#pragma mark -- lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.sd_layout.leftEqualToView(self.view).topSpaceToView(self.view, 64).rightEqualToView(self.view).bottomEqualToView(self.view);
}

//=================================================================
//                       UITableViewDataSource
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

//=================================================================
//                       UITableViewDelegate
#pragma mark - UITableViewDelegate

//=================================================================
//                           懒加载
#pragma mark -- getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}


@end
