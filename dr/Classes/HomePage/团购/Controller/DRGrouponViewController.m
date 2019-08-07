//
//  DRGrouponViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGrouponViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRLoginViewController.h"
#import "DRGrouponSearchViewController.h"
#import "DRMyGrouponViewController.h"
#import "DRGrouponTableViewCell.h"
#import "DRDateTool.h"
#import "UITableView+DRNoData.h"

@interface DRGrouponViewController () <UITableViewDelegate, UITableViewDataSource, GrouponTableViewCellDelegate>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, copy) NSString *sortStr;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DRGrouponViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSetDeadlineTimer];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSetDeadlineTimer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"拼团中";
    [self setupChilds];
    self.pageIndex = 1;
    waitingView
    [self getGrouponData];
    
    //刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"RefreshGrouponNote" object:nil];
}

#pragma mark - 请求数据
- (void)getGrouponData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              };
   
    NSDictionary *headDic = @{
                              @"cmd":@"S02",
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            //添加数据
            NSArray * dataArray = [DRGrouponModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArray];
            [self removeOverdueGood];
            [self.tableView reloadData];
            //结束刷新
            [self.headerView endRefreshing];
            if (dataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            //结束刷新
            [self.headerView endRefreshing];
            [self.footerView endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChilds
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"我的团" style:UIBarButtonItemStylePlain target:self action:@selector(myGrouponBarClick)];;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(grouponSearchBarClick)];

    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - tabBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerView;
    [DRTool setRefreshHeaderData:headerView];
    tableView.mj_header = headerView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    tableView.mj_footer = footerView;
}
- (void)myGrouponBarClick
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    DRMyGrouponViewController * myGrouponVC = [[DRMyGrouponViewController alloc] init];
    [self.navigationController pushViewController:myGrouponVC animated:YES];
}
//搜索
- (void)grouponSearchBarClick
{
    DRGrouponSearchViewController * grouponSearchVC = [[DRGrouponSearchViewController alloc] init];
    [self.navigationController pushViewController:grouponSearchVC animated:YES];
}
#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self getGrouponData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex ++;
    [self getGrouponData];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"没有相关商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGrouponTableViewCell * cell = [DRGrouponTableViewCell cellWithTableView:tableView];
    cell.model = self.dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 9 + 129;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    DRGrouponModel *grouponModel = self.dataArray[indexPath.row];
    goodDetailVC.grouponId = grouponModel.id;
    goodDetailVC.isGroupon = YES;
    [self.navigationController pushViewController:goodDetailVC animated:YES];
}
- (void)grouponTableViewCell:(DRGrouponTableViewCell *)cell joinGrouponButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    DRGrouponModel *grouponModel = self.dataArray[indexPath.row];
    goodDetailVC.grouponId = grouponModel.id;
    goodDetailVC.isGroupon = YES;
    [self.navigationController pushViewController:goodDetailVC animated:YES];
}
#pragma mark - 倒计时
- (void)addSetDeadlineTimer
{
    if(self.timer == nil)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}
- (void)setTimeLabelText
{
    [self removeOverdueGood];
//    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GroupCountDownNotification" object:nil];
}
- (void)removeOverdueGood
{
    //过滤已过期商品
    NSMutableArray * dataArray = [NSMutableArray array];
    for (DRGrouponModel * grouponModel in self.dataArray) {
        NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:grouponModel.createTime + 2 * 24 * 60 * 60 * 1000];
        if (components.day > 0 || components.hour > 0 || components.minute > 0 || components.second > 0) {
            [dataArray addObject:grouponModel];
        }
    }
    self.dataArray = dataArray;
}
#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma  mark - 销毁对象
- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
