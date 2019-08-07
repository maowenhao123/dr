//
//  DRGradeDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/8/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGradeDetailViewController.h"
#import "DRRedPacketTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRGradeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation DRGradeDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"积分";
    [self setupChilds];
}

- (void)setupChilds
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0) {
        [tableView showNoDataWithTitle:@"" description:@"暂无积分" rowCount:0];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRRedPacketTableViewCell *cell = [DRRedPacketTableViewCell cellWithTableView:tableView];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 9 + 35 + 64;
}

@end
