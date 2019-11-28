//
//  DRGoodGroupUserViewController.m
//  dr
//
//  Created by dahe on 2019/11/20.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodGroupUserViewController.h"
#import "DRGoodGroupTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRGoodGroupUserViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic,weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;//页数

@end

@implementation DRGoodGroupUserViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"拼团中";
    self.pageIndex = 1;
    [self getData];
    [self setupChilds];
}

#pragma mark - 请求数据
- (void)getData
{
    
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}

#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
    [tableView showNoDataWithTitle:@"" description:@"暂无数据" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodGroupTableViewCell *cell = [DRGoodGroupTableViewCell cellWithTableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
