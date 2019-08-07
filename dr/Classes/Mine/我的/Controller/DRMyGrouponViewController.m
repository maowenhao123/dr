//
//  DRMyGrouponViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/8/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMyGrouponViewController.h"
#import "DROrderDetailViewController.h"
#import "DRShopDetailViewController.h"
#import "DROrderListHeaderView.h"
#import "DROrderListFooterView.h"
#import "DROrderGroupTableViewCell.h"
#import "UITableView+DRNoData.h"
#import "DRShareTool.h"

@interface DRMyGrouponViewController ()<UITableViewDataSource, UITableViewDelegate, DROrderListFooterViewDelegate>

@property (nonatomic, assign) int pageIndex1;//全部
@property (nonatomic, assign) int pageIndex2;//拼团中
@property (nonatomic, assign) int pageIndex3;//拼团成功
@property (nonatomic, assign) int pageIndex4;//拼团失败
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRMyGrouponViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的拼团";
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.pageIndex3 = 1;
    self.pageIndex4 = 1;
    self.currentPageIndex = 1;
    [self setupChilds];
}
#pragma mark - 请求数据
- (void)getData
{
    NSNumber *status;
    if (self.currentIndex == 1) {//拼团中
        status = @(5);
    }else if (self.currentIndex == 2) {//拼团成功
        status = @(10);
    }else if (self.currentIndex == 3) {//拼团失败
        status = @(-5);
    }
    
    NSDictionary *bodyDic_ = @{
                               @"pageIndex":@(self.currentPageIndex),
                               @"pageSize":DRPageSize,
                               };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (status) {
        [bodyDic setObject:status forKey:@"status"];
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S32",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
            NSArray * newDataArray_ = [DROrderModel  mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSArray *orders = json[@"list"];
            for (DROrderModel * orderModel in newDataArray_) {
                NSInteger index = [newDataArray_ indexOfObject:orderModel];
                NSArray *storeOrders_ = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:orders[index][@"storeOrders"]];
                orderModel.storeOrders = storeOrders_;
                
                NSArray *detail = orders[index][@"storeOrders"];
                for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                    NSInteger index_ = [orderModel.storeOrders indexOfObject:storeOrder];
                    NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:detail[index_][@"detail"]];
                    storeOrder.detail = detail_;
                }
            }
            
            [dataArray_ addObjectsFromArray:newDataArray_];
            [tableView reloadData];
            if (newDataArray_.count == 0) {//没有新的数据
                [footerView endRefreshingWithNoMoreData];
            }else
            {
                [footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
        }
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
        if ([footerView isRefreshing]) {
            [footerView endRefreshing];
        }
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //添加btnTitle
    self.btnTitles = @[@"全部", @"拼团中", @"拼团成功", @"拼团失败"];
    //添加tableview
    CGFloat scrollViewH = screenHeight-statusBarH-navBarH-topBtnH;
    for(int i = 0;i < self.btnTitles.count;i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH) style:UITableViewStyleGrouped];
        tableView.tag = i;
        tableView.backgroundColor = DRBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
        [self.views addObject:tableView];
        
        //初始化头部刷新控件
        MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
        [DRTool setRefreshHeaderData:headerView];
        [self.headerViews addObject:headerView];
        tableView.mj_header = headerView;
        
        //初始化底部刷新控件
        MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
        [DRTool setRefreshFooterData:footerView];
        [self.footerViews addObject:footerView];
        tableView.mj_footer = footerView;
    }
    //完成配置
    [super configurationComplete];
    [super topBtnClick:self.topBtns[self.currentIndex]];
}
- (void)changeCurrentIndex:(int)currentIndex
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    //没有数据时加载数据
    if(dataArray_.count == 0)
    {
        [self getData];
    }
}
#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    if(self.currentIndex == 0)
    {
        self.pageIndex1 = 1;
    }else if(self.currentIndex == 1)
    {
        self.pageIndex2 = 1;
    }else if(self.currentIndex == 2)
    {
        self.pageIndex3 = 1;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 = 1;
    }
    self.currentPageIndex = 1;
    //清空数据
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    [dataArray_ removeAllObjects];
    //请求数据
    [self getData];
}
- (void)footerRefreshViewBeginRefreshing
{
    if(self.currentIndex == 0)
    {
        self.pageIndex1 += 1;
        self.currentPageIndex = self.pageIndex1;
    }else if(self.currentIndex == 1)
    {
        self.pageIndex2 += 1;
        self.currentPageIndex = self.pageIndex2;
    }else if(self.currentIndex == 2)
    {
        self.pageIndex3 += 1;
        self.currentPageIndex = self.pageIndex3;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 += 1;
        self.currentPageIndex = self.pageIndex4;
    }
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"您还没有相关的订单" description:@"去买个多肉萌翻自己~" rowCount:dataArray_.count];
    return dataArray_.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[section];
    return orderModel.storeOrders.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[indexPath.section];
    DROrderGroupTableViewCell *cell = [DROrderGroupTableViewCell cellWithTableView:tableView];
    cell.orderModel = orderModel;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9 + 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[section];
    int statusInt = [orderModel.status intValue];
    if (statusInt == 5) {//拼团中 显示分享按钮
        return 35 + 40;
    }
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DROrderListHeaderView *headerView = [DROrderListHeaderView headerFooterViewWithTableView:tableView];
    headerView.tag = section;
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[section];
    headerView.isGroup = YES;
    headerView.orderModel = orderModel;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewDidClick:)];
    [headerView addGestureRecognizer:tap];
    
    return headerView;
}

- (void)headerViewDidClick:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[view.tag];
    if (orderModel.storeOrders.count == 1) {
        DRShopDetailViewController * shopVC = [DRShopDetailViewController new];
        DRStoreOrderModel * storeOrderModel = orderModel.storeOrders.firstObject;
        shopVC.shopId = storeOrderModel.storeId;
        [self.navigationController pushViewController:shopVC animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    DROrderListFooterView *footerView = [DROrderListFooterView headerFooterViewWithTableView:tableView];
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[section];
    footerView.index = section;
    footerView.isGroup = YES;
    footerView.orderModel = orderModel;
    footerView.delegate = self;
    return footerView;
}

- (void)buttonDidClick:(UIButton *)button
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel *orderModel = dataArray_[button.tag];
    
    [DRShareTool shareGrouponByGrouponId:orderModel.group.id];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DROrderDetailViewController * orderDetailVC = [[DROrderDetailViewController alloc] init];
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel *orderModel = dataArray_[indexPath.section];
    orderDetailVC.orderId = orderModel.id;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}
#pragma mark - 初始化
- (NSMutableArray *)headerViews
{
    if(_headerViews == nil)
    {
        _headerViews = [NSMutableArray array];
    }
    return _headerViews;
}
- (NSMutableArray *)footerViews
{
    if(_footerViews == nil)
    {
        _footerViews = [NSMutableArray array];
    }
    return _footerViews;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}

@end
