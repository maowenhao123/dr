//
//  DROrderListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderListViewController.h"
#import "DROrderDetailViewController.h"
#import "DRReturnGoodViewController.h"
#import "DRPayViewController.h"
#import "DRCommentOrderListViewController.h"
#import "DRSellerLogisticsViewController.h"
#import "DRReturnGoodOrderListViewController.h"
#import "DRShopDetailViewController.h"
#import "DROrderListHeaderView.h"
#import "DROrderListFooterView.h"
#import "DROrderMultipTableViewCell.h"
#import "DROrderSingleTableViewCell.h"
#import "DROrderGroupTableViewCell.h"
#import "DRShareTool.h"
#import "UITableView+DRNoData.h"
#import "DRDateTool.h"

@interface DROrderListViewController ()<UITableViewDataSource, UITableViewDelegate, DROrderListFooterViewDelegate>

@property (nonatomic, assign) int pageIndex1;//全部
@property (nonatomic, assign) int pageIndex2;//待付款
@property (nonatomic, assign) int pageIndex3;//待成团
@property (nonatomic, assign) int pageIndex4;//待发货
@property (nonatomic, assign) int pageIndex5;//待收货
@property (nonatomic, assign) int pageIndex6;//已完成
@property (nonatomic, assign) int pageIndex7;//已取消
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DROrderListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSetDeadlineTimer];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSetDeadlineTimer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的订单";
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.pageIndex3 = 1;
    self.pageIndex4 = 1;
    self.pageIndex5 = 1;
    self.pageIndex6 = 1;
    self.pageIndex7 = 1;
    self.currentPageIndex = 1;
    [self setupChilds];
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"orderListRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"orderDetailRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"upDataOrderStatus" object:nil];
}
#pragma mark - 请求数据
- (void)getData
{
    NSNumber *status;
    if (self.currentIndex == 1) {//待付款
        status = @(0);
    }else if (self.currentIndex == 2) {//待发货
        status = @(10);
    }else if (self.currentIndex == 3) {//待收货
        status = @(20);
    }else if (self.currentIndex == 4) {//已完成
        status = @(30);
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
                              @"cmd":@"S11",
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
                NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:orderModel.createTime + 15 * 60 * 1000];
                if (components.minute > 0 || components.second > 0 || orderModel.status != 0) {
                    [dataArray_ addObject:orderModel];
                }
            }
            
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
- (void)confirmOrderWithOrderId:(NSString *)orderId
{
    NSDictionary *bodyDic = @{
                              @"id":orderId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S08",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self headerRefreshViewBeginRefreshing];
            DRCommentOrderListViewController * commentOrderVC = [[DRCommentOrderListViewController alloc] init];
            commentOrderVC.orderId = orderId;
            [self.navigationController pushViewController:commentOrderVC animated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)cancelOrderWithOrderModel:(DROrderModel *)orderModel
{
    NSDictionary *bodyDic = @{
                              @"id":orderModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S07",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self headerRefreshViewBeginRefreshing];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];

}
- (void)deleteOrderWithOrderModel:(DROrderModel *)orderModel
{
    NSDictionary *bodyDic = @{
                              @"id":orderModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self headerRefreshViewBeginRefreshing];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //添加btnTitle
    self.btnTitles = @[@"全部", @"待付款", @"待发货", @"待收货", @"已完成"];
    self.maxViewCount = 5;
    //添加tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCountDownNotification" object:nil];
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
    }else if(self.currentIndex == 4)
    {
        self.pageIndex5 = 1;
    }else if(self.currentIndex == 5)
    {
        self.pageIndex6 = 1;
    }else if(self.currentIndex == 6)
    {
        self.pageIndex7 = 1;
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
    }else if(self.currentIndex == 4)
    {
        self.pageIndex5 += 1;
        self.currentPageIndex = self.pageIndex5;
    }else if(self.currentIndex == 5)
    {
        self.pageIndex6 += 1;
        self.currentPageIndex = self.pageIndex6;
    }else if(self.currentIndex == 6)
    {
        self.pageIndex7 += 1;
        self.currentPageIndex = self.pageIndex7;
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[indexPath.section];
    if ([orderModel.orderType integerValue] == 2) {
        DROrderGroupTableViewCell *cell = [DROrderGroupTableViewCell cellWithTableView:tableView];
        cell.orderModel = orderModel;
        return cell;
    }else
    {
        NSMutableArray * detailArray = [NSMutableArray array];
        for (DRStoreOrderModel *storeOrders in orderModel.storeOrders) {
            for (DROrderItemDetailModel *detail in storeOrders.detail) {
                [detailArray addObject:detail];
            }
        }

        if (detailArray.count == 1) {
            DROrderSingleTableViewCell *cell = [DROrderSingleTableViewCell cellWithTableView:tableView];
            cell.storeOrderModel = orderModel.storeOrders[indexPath.row];;
            return cell;
        }else
        {
            DROrderMultipTableViewCell *cell = [DROrderMultipTableViewCell cellWithTableView:tableView];
            cell.orderModel = orderModel;
            return cell;
        }
    }
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
    NSInteger status = [orderModel.status integerValue];
    if (status == 0 || status == 5 || status == 20 || status == 30 || status == -1) {//显示底部按钮
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
    footerView.orderModel = orderModel;
    footerView.delegate = self;
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DROrderDetailViewController * orderDetailVC = [[DROrderDetailViewController alloc] init];
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel *orderModel = dataArray_[indexPath.section];
    orderDetailVC.orderId = orderModel.id;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}

- (void)buttonDidClick:(UIButton *)button
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel *orderModel = dataArray_[button.tag];
    
    if ([button.currentTitle isEqualToString:@"查看物流"])
    {
        DRSellerLogisticsViewController * sellerLogisticsVC = [[DRSellerLogisticsViewController alloc] init];
        sellerLogisticsVC.orderId = orderModel.id;
        [self.navigationController pushViewController:sellerLogisticsVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"确认收货"])
    {
        [self confirmOrderWithOrderId:orderModel.id];
    }else if ([button.currentTitle isEqualToString:@"删除订单"])
    {
        [self deleteOrderWithOrderModel:orderModel];
    }else if ([button.currentTitle isEqualToString:@"取消订单"])
    {
        [self cancelOrderWithOrderModel:orderModel];
    }else if ([button.currentTitle isEqualToString:@"去支付"])
    {
        DRPayViewController * payVC = [[DRPayViewController alloc] init];
        payVC.type = 1;
        payVC.orderId = orderModel.id;
        payVC.grouponType = 0;
        payVC.price = [orderModel.amountPayable doubleValue] / 100;
        [self.navigationController pushViewController:payVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"去评价"])
    {
        DRCommentOrderListViewController * commentOrderVC = [[DRCommentOrderListViewController alloc] init];
        commentOrderVC.orderId = orderModel.id;
        [self.navigationController pushViewController:commentOrderVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"退款"])
    {
        DRReturnGoodOrderListViewController* returnGoodListVC = [[DRReturnGoodOrderListViewController alloc] init];
        returnGoodListVC.orderId = orderModel.id;
        [self.navigationController pushViewController:returnGoodListVC animated:YES];
    }else if ([button.currentTitle isEqualToString:@"邀请好友拼团"])
    {
        [DRShareTool shareGrouponByGrouponId:orderModel.group.id];
    }
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
        for (int i = 0; i < 7; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}
#pragma mark - 销毁对象
- (void)removeSetDeadlineTimer
{
    [self.timer invalidate];
    self.timer = nil;
}


@end
