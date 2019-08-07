//
//  DRWaitSettlementOrderViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/6/11.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRWaitSettlementOrderViewController.h"
#import "DRShipmentDetailViewController.h"
#import "DRShipmentDetaiSingleTableViewCell.h"
#import "DRShipmentDetaiMultipleTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRWaitSettlementOrderViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;

@end

@implementation DRWaitSettlementOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"待结算";
    self.pageIndex = 1;
    [self setupChilds];
    waitingView
    [self getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"NoGoodsNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"shipmentSuccess" object:nil];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                               @"pageIndex":@(self.pageIndex),
                               @"pageSize":DRPageSize,
                               };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S19",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * newDataArray = [DROrderModel  mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSArray *orders = json[@"list"];
            for (DROrderModel * orderModel in newDataArray) {
                NSInteger index = [newDataArray indexOfObject:orderModel];
                NSArray *storeOrders_ = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:orders[index][@"storeOrders"]];
                orderModel.storeOrders = storeOrders_;
                
                NSArray *detail = orders[index][@"storeOrders"];
                for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                    NSInteger index_ = [orderModel.storeOrders indexOfObject:storeOrder];
                    NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:detail[index_][@"detail"]];
                    storeOrder.detail = detail_;
                }
            }
            
            [self.dataArray addObjectsFromArray:newDataArray];
            [self.tableView reloadData];
            if (newDataArray.count == 0) {//没有新的数据
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            if ([self.footerView isRefreshing]) {
                [self.footerView endRefreshing];
            }
        }
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
        if ([self.footerView isRefreshing]) {
            [self.footerView endRefreshing];
        }
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    CGFloat viewH = screenHeight - statusBarH - navBarH;
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, viewH) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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

- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self getData];
}

- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"您还没有相关的订单" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DROrderModel * orderModel = self.dataArray[indexPath.row];
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
    DROrderModel * orderModel = self.dataArray[indexPath.row];
    shipmentDetailVC.orderId = orderModel.id;
    shipmentDetailVC.orderType = orderModel.orderType;
    [self.navigationController pushViewController:shipmentDetailVC animated:YES];
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
