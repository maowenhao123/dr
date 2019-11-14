//
//  DRChooseGoodViewController.m
//  dr
//
//  Created by dahe on 2019/11/4.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRChooseGoodViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRChooseGoodTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRChooseGoodViewController ()<UITableViewDataSource, UITableViewDelegate, ChooseSeckillGoodTableViewCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;

@end

@implementation DRChooseGoodViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的商品";
    [self setupChilds];
    self.pageIndex = 1;
    waitingView
    [self getGoodData];
}

#pragma mark - 请求数据
- (void)getGoodData
{
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"sellType": @"1",
                              @"storeId":myShopModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray *goodDataArray = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:goodDataArray];
            [self.tableView reloadData];
            
            [self.headerView endRefreshing];
            if (goodDataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            [self.headerView endRefreshing];
            [self.footerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableview
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)];
    headerView.backgroundColor = DRBackgroundColor;
    tableView.tableHeaderView = headerView;
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    tableView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    tableView.mj_footer = footerView;
}

- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self getGoodData];
}

- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getGoodData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"暂无商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRChooseGoodTableViewCell *cell = [DRChooseGoodTableViewCell cellWithTableView:tableView];
    cell.goodModel = self.dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    DRGoodModel * goodModel = self.dataArray[indexPath.row];
    goodVC.goodId = goodModel.id;
    [self.navigationController pushViewController:goodVC animated:YES];
}

#pragma mark - 协议
- (void)chooseSeckillGoodTableViewCell:(DRChooseGoodTableViewCell *)cell buttonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    DRGoodModel * goodModel = self.dataArray[indexPath.row];
    
    if (_delegate && [_delegate respondsToSelector:@selector(ChooseGoodViewControllerChooseGoodModel:)]) {
        [_delegate ChooseGoodViewControllerChooseGoodModel:goodModel];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
