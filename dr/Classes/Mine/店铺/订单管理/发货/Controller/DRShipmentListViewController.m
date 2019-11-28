//
//  DRShipmentListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentListViewController.h"
#import "DRShipmentDetailViewController.h"
#import "DRShipmentDetaiSingleTableViewCell.h"
#import "DRShipmentDetaiMultipleTableViewCell.h"
#import "DRChangeGrouponNumberView.h"
#import "UITableView+DRNoData.h"

@interface DRShipmentListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) int pageIndex1;
@property (nonatomic, assign) int pageIndex2;
@property (nonatomic, assign) int pageIndex3;
@property (nonatomic, assign) int pageIndex4;
@property (nonatomic, assign) int pageIndex5;
@property (nonatomic, assign) int pageIndex6;
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRShipmentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单管理";
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.pageIndex3 = 1;
    self.pageIndex4 = 1;
    self.pageIndex5 = 1;
    self.pageIndex6 = 1;
    self.currentPageIndex = 1;
    [self setupChilds];
    waitingView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeGrouponNumber:) name:@"ChangeGrouponNumberNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"NoGoodsNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shipmentSuccess) name:@"shipmentSuccess" object:nil];
}

- (void)ChangeGrouponNumber:(NSNotification*)notification
{
    NSDictionary * objectDic = notification.object;
    
    if ([objectDic[@"goSendGood"] boolValue]) {
        NSMutableArray * dataArray2 = self.dataArray[2];
        [dataArray2 removeAllObjects];
        NSMutableArray * dataArray3 = self.dataArray[3];
        [dataArray3 removeAllObjects];
        [self topBtnClick:self.topBtns[3]];
    }else
    {
        NSMutableArray * dataArray2 = self.dataArray[2];
        [dataArray2 removeAllObjects];
        NSMutableArray * dataArray3 = self.dataArray[3];
        [dataArray3 removeAllObjects];
        [self headerRefreshViewBeginRefreshing];
    }
}

- (void)shipmentSuccess
{
    NSMutableArray * dataArray_ = self.dataArray[3];
    [dataArray_ removeAllObjects];
    [self headerRefreshViewBeginRefreshing];
}

#pragma mark - 请求数据
- (void)getData
{
    NSNumber *status;
    NSString * cmd = @"S20";
    if (self.currentIndex == 1) {//待付款
        status = @(0);
    }else if (self.currentIndex == 2) {//待成团
        cmd = @"S34";
    }else if (self.currentIndex == 3) {//待发货
        status = @(10);
    }else if (self.currentIndex == 4) {//已发货
        status = @(20);
    }else if (self.currentIndex == 5) {//已完成
        status = @(30);
    }

    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionary];
    if (self.currentIndex == 2) {//待成团
        [bodyDic setObject:UserId forKey:@"userid"];
    }else
    {
        NSDictionary *bodyDic_ = @{
                                   @"pageIndex":@(self.currentPageIndex),
                                   @"pageSize":DRPageSize,
                                   };
        bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
        if (status) {
            [bodyDic setObject:status forKey:@"status"];
        }
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
            NSArray * newDataArray_ = [DROrderModel  mj_objectArrayWithKeyValuesArray:json[@"list"]];
            if (self.currentIndex == 2) {//待成团
                for (DROrderModel * orderModel in newDataArray_) {
                    orderModel.status = @(5);
                }
            }
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
- (void)setupChilds
{
    //添加btnTitle
    self.btnTitles = @[@"全部",@"待付款",@"待成团",@"待发货",@"已发货",@"已收货"];
    self.maxViewCount = 6;
    //添加tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0;i < self.btnTitles.count;i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH)];
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
    }else if(self.currentIndex == 4)
    {
        self.pageIndex5 = 1;
    }else if(self.currentIndex == 5)
    {
        self.pageIndex6 = 1;
    }
    self.currentPageIndex = 1;
    //清空数据
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
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
    }
    
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"您还没有相关的订单" rowCount:dataArray_.count];
    return dataArray_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[indexPath.row];
    if (orderModel.storeOrders.firstObject.detail.count == 1) {
        DRShipmentDetaiSingleTableViewCell *cell = [DRShipmentDetaiSingleTableViewCell cellWithTableView:tableView];
        cell.orderModel = orderModel;
        return cell;
    }else
    {
        DRShipmentDetaiMultipleTableViewCell *cell = [DRShipmentDetaiMultipleTableViewCell cellWithTableView:tableView];
        cell.orderModel = orderModel;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 9 + 35 + 100 + 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRShipmentDetailViewController * shipmentDetailVC = [[DRShipmentDetailViewController alloc] init];
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DROrderModel * orderModel = dataArray_[indexPath.row];
    shipmentDetailVC.orderId = orderModel.id;
    shipmentDetailVC.orderType = orderModel.orderType;
    if (self.currentIndex == 2) {
        shipmentDetailVC.isWaitPending = YES;
    }
    [self.navigationController pushViewController:shipmentDetailVC animated:YES];
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
        for (int i = 0; i < 6; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}
@end
