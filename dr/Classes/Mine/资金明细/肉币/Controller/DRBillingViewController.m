//
//  DRBillingViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/6/19.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBillingViewController.h"
#import "DRBillingDetailViewController.h"
#import "DRBillingScreeningViewController.h"
#import "DRRechargeViewController.h"
#import "DRMoneyDetailTableViewCell.h"
#import "DRBillingHeaderView.h"
#import "DRDateTool.h"
#import "NSDate+DR.h"
#import "UITableView+DRNoData.h"

@interface DRBillingViewController ()<UITableViewDataSource, UITableViewDelegate, BillingScreeningViewControllerDelegate>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *moneyDetailListArray;
@property (nonatomic, strong) NSMutableArray *moneyDetailSectionListArray;
@property (nonatomic, assign) int pageIndex;//当前的页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, copy) NSString *monthStr;
@property (nonatomic, copy) NSString *beginTimeStr;
@property (nonatomic, copy) NSString *endTimeStr;

@end

@implementation DRBillingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"账单";
    self.pageIndex = 1;
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    //inType 1 为收入，2 支出 不传参数或其他值，为全部
    NSDictionary *bodyDic_ = @{
                               @"pageIndex":@(self.pageIndex),
                               @"pageSize":DRPageSize,
                               };
    NSString * cmd;
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (self.isShop) {
        cmd = @"S50";
        if (!DRStringIsEmpty(self.monthStr)) {
            NSString *beginTime = [NSString stringWithFormat:@"%@-01", self.monthStr];
            [bodyDic setObject:beginTime forKey:@"beginTime"];
        }else if (!DRStringIsEmpty(self.beginTimeStr) && !DRStringIsEmpty(self.endTimeStr))
        {
            [bodyDic setObject:self.beginTimeStr forKey:@"beginTime"];
            [bodyDic setObject:self.endTimeStr forKey:@"endTime"];
        }
    }else{
        cmd = @"U20";
    }
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray *moneyDetailList = [DRMoneyDetailModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRMoneyDetailModel * moneyDetailModel in moneyDetailList) {
                NSInteger index = [moneyDetailList indexOfObject:moneyDetailModel];
                NSDictionary * dic = json[@"list"][index][@"detail"];
                DROrderModel *orderModel = [DROrderModel mj_objectWithKeyValues:dic];
                NSArray *storeOrders_ = [DRStoreOrderModel  mj_objectArrayWithKeyValuesArray:dic[@"storeOrders"]];
                orderModel.storeOrders = storeOrders_;
                for (DRStoreOrderModel * storeOrder in orderModel.storeOrders) {
                    NSInteger index_ = [orderModel.storeOrders indexOfObject:storeOrder];
                    NSArray *detail_ = [DROrderItemDetailModel  mj_objectArrayWithKeyValuesArray:dic[@"storeOrders"][index_][@"detail"]];
                    storeOrder.detail = detail_;
                }
                moneyDetailModel.detail = orderModel;
            }
            [self.moneyDetailListArray addObjectsFromArray:moneyDetailList];
            [self setMonthStatus];//设置数据
            [self.tableView reloadData];//刷新数据
            if ([self.footerView isRefreshing]) {
                if (moneyDetailList.count == 0) {//没有新的数据
                    [self.footerView endRefreshingWithNoMoreData];
                }else
                {
                    [self.footerView endRefreshing];
                }
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

- (void)setMonthStatus
{
    NSMutableArray *orderSectionList = self.moneyDetailSectionListArray;
    [orderSectionList removeAllObjects];//先清空之前的数据
    if (self.moneyDetailListArray.count == 0) return;//没有数据就return

    if (self.isShop && !DRStringIsEmpty(self.monthStr)) {
        DRMoneyDetailSectionModel *sectionModel = [[DRMoneyDetailSectionModel alloc] init];
        sectionModel.moneyDetails = self.moneyDetailListArray;
        sectionModel.month = self.monthStr;//section标题
        [orderSectionList addObject:sectionModel];
        
        DRMoneyDetailModel *moneyDetailModel = self.moneyDetailListArray.lastObject;
        NSString *beginTime = [DRDateTool getTimeByTimestamp:moneyDetailModel.createTime format:@"yyyy-MM"];
        beginTime = [NSString stringWithFormat:@"%@-01", beginTime];
        [self getIncomeAndExpenditureWithBeginTime:beginTime endTime:@""];
    }else if (self.isShop && !DRStringIsEmpty(self.beginTimeStr) && !DRStringIsEmpty(self.endTimeStr))
    {
        DRMoneyDetailSectionModel *sectionModel = [[DRMoneyDetailSectionModel alloc] init];
        sectionModel.moneyDetails = self.moneyDetailListArray;
        sectionModel.month = [NSString stringWithFormat:@"%@至%@", self.beginTimeStr, self.endTimeStr];//section标题
        [orderSectionList addObject:sectionModel];
        [self getIncomeAndExpenditureWithBeginTime:self.beginTimeStr endTime:self.endTimeStr];
    }else
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        //获得当前时间的月份
        NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        for (int i = 0; i < self.moneyDetailListArray.count; i++) {//月份
            DRMoneyDetailModel *model = self.moneyDetailListArray[i];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.createTime / 1000];
            if (date.month == nowCmps.month && date.year == nowCmps.year)
            {
                model.month = @"本月";
            }else
            {
                model.month = [NSString stringWithFormat:@"%ld月",(long)date.month];
            }
        }
        
        //对数据进行时间分组后的数组，元素是数组，元素数组的元素的时间是同一月
        NSMutableArray *timeSortedModelArray = [NSMutableArray array];
        for(int i = 0;i < self.moneyDetailListArray.count;i++)
        {
            DRMoneyDetailModel *model = self.moneyDetailListArray[i];
            if(i == 0)//先把第一个放进去
            {
                NSMutableArray *muArr = [NSMutableArray array];
                [muArr addObject:model];
                [timeSortedModelArray addObject:muArr];
            }else
            {
                NSMutableArray *muArr = [timeSortedModelArray lastObject];
                DRMoneyDetailModel *lastModel = [muArr lastObject];
                //对code进行比较，是否同一月
                BOOL isequalMonth = [model.month isEqualToString:lastModel.month];
                if(isequalMonth)//同一月
                {
                    [muArr addObject:model];
                }else//不是同一月
                {
                    //新建一个数组放不同时间的数据，数组放入timeSortedStatusArray
                    NSMutableArray *muArr = [NSMutableArray array];
                    [muArr addObject:model];
                    [timeSortedModelArray addObject:muArr];
                }
            }
        }
        
        for(int i = 0;i < timeSortedModelArray.count;i++)
        {
            DRMoneyDetailSectionModel *sectionModel = [[DRMoneyDetailSectionModel alloc] init];
            sectionModel.moneyDetails = timeSortedModelArray[i];//比赛信息
            DRMoneyDetailModel *model = [sectionModel.moneyDetails firstObject];
            sectionModel.createTime = model.createTime;
            sectionModel.month = model.month;//section标题
            [orderSectionList addObject:sectionModel];
        }
        
        [self getMonthIncomeAndExpenditure];
    }
}

- (void)getMonthIncomeAndExpenditure
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"D01",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray * listMonth = json[@"listMonth"];
            for (NSDictionary * dic in listMonth) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dic[@"month"] longLongValue]/ 1000];
                for (DRMoneyDetailSectionModel *sectionModel in self.moneyDetailSectionListArray) {
                    NSDate *date_ = [NSDate dateWithTimeIntervalSince1970:sectionModel.createTime / 1000];
                    if (date.year == date_.year && date.month == date_.month) {
                        sectionModel.income = [NSString stringWithFormat:@"%@", dic[@"income"]];
                        sectionModel.expenditure = [NSString stringWithFormat:@"%@", dic[@"expenditure"]];
                    }
                }
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)getIncomeAndExpenditureWithBeginTime:(NSString *)beginTime endTime:(NSString *)endTime
{
    NSDictionary *bodyDic_ = @{
                               @"beginTime":beginTime,
                               };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(endTime)) {
        [bodyDic setObject:endTime forKey:@"endTime"];
    }
    NSLog(@"bodyDic:%@", bodyDic);
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"C14",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSMutableArray *moneyDetailSectionList = self.moneyDetailSectionListArray;
            DRMoneyDetailSectionModel *sectionModel = moneyDetailSectionList[0];
            sectionModel.income = [NSString stringWithFormat:@"%@", json[@"month"][@"income"]];
            sectionModel.expenditure = [NSString stringWithFormat:@"%@", json[@"month"][@"expenditure"]];
            [UIView performWithoutAnimation:^{
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    if (!self.isShop) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(rechargeBarDidClick)];
    }
    
    //tableview
    CGFloat tableViewH = screenHeight - statusBarH - navBarH;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, tableViewH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
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
    
    //时间筛选
    if (self.isShop) {
        UIButton * chooseTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseTimeButton.frame = CGRectMake(screenWidth - 20 - 48, screenHeight - statusBarH - navBarH - 20 - 48, 48, 48);
        [chooseTimeButton setImage:[UIImage imageNamed:@"choose_billing_time"] forState:UIControlStateNormal];
        [chooseTimeButton addTarget:self action:@selector(screeningButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:chooseTimeButton];
    }
}

- (void)rechargeBarDidClick
{
    DRRechargeViewController * rechargeVC = [[DRRechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeVC animated:YES];
}

- (void)screeningButtonDidClick
{
    DRBillingScreeningViewController * billingScreeningVC = [[DRBillingScreeningViewController alloc] init];
    billingScreeningVC.delegate = self;
    if (!DRStringIsEmpty(self.monthStr)) {
        billingScreeningVC.monthStr = self.monthStr;
    }
    if (!DRStringIsEmpty(self.beginTimeStr) && !DRStringIsEmpty(self.endTimeStr)) {
        billingScreeningVC.beginTimeStr = self.beginTimeStr;
        billingScreeningVC.endTimeStr = self.endTimeStr;
    }
    [self.navigationController pushViewController:billingScreeningVC animated:YES];
}

- (void)billingScreeningByMonth:(NSString *)monthStr
{
    self.monthStr = monthStr;
    self.beginTimeStr = nil;
    self.endTimeStr = nil;
    //清空数据
    [self.moneyDetailListArray removeAllObjects];
    [self headerRefreshViewBeginRefreshing];
}

- (void)billingScreeningByBeginTimeStr:(NSString *)beginTimeStr endTimeStr:(NSString *)endTimeStr
{
    self.monthStr = nil;
    self.beginTimeStr = beginTimeStr;
    self.endTimeStr = endTimeStr;
    //清空数据
    [self.moneyDetailListArray removeAllObjects];
    [self headerRefreshViewBeginRefreshing];
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    //清空数据
    [self.moneyDetailListArray removeAllObjects];
    //请求数据
    [self getData];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex += 1;
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView showNoDataWithTitle:@"" description:@"您还没有相关的记录" rowCount:self.moneyDetailSectionListArray.count];
    
    return self.moneyDetailSectionListArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DRMoneyDetailSectionModel *sectionModel = self.moneyDetailSectionListArray[section];
    return sectionModel.moneyDetails.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMoneyDetailTableViewCell *cell = [DRMoneyDetailTableViewCell cellWithTableView:tableView];
    DRMoneyDetailSectionModel *sectionModel = self.moneyDetailSectionListArray[indexPath.section];
    cell.model = sectionModel.moneyDetails[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isShop) {
        return 50;
    }
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DRBillingHeaderView *headerView = [DRBillingHeaderView headerFooterViewWithTableView:tableView];
    headerView.tag = section;
    DRMoneyDetailSectionModel *sectionModel = self.moneyDetailSectionListArray[section];
    headerView.sectionModel = sectionModel;
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMoneyDetailSectionModel *sectionModel = self.moneyDetailSectionListArray[indexPath.section];
    DRMoneyDetailModel * model = sectionModel.moneyDetails[indexPath.row];
    if ([model.type intValue] == 3 && !DRObjectIsEmpty(model.detail))//只有结算做详情展示
    {
        DRBillingDetailViewController * billingDetailVC = [[DRBillingDetailViewController alloc] init];
        billingDetailVC.moneyDetailmodel = model;
        [self.navigationController pushViewController:billingDetailVC animated:YES];
    }
}

#pragma mark - 初始化
- (NSMutableArray *)moneyDetailListArray
{
    if(_moneyDetailListArray == nil)
    {
        _moneyDetailListArray = [NSMutableArray array];
    }
    return _moneyDetailListArray;
}
- (NSMutableArray *)moneyDetailSectionListArray
{
    if(_moneyDetailSectionListArray == nil)
    {
        _moneyDetailSectionListArray = [NSMutableArray array];
    }
    return _moneyDetailSectionListArray;
}

@end
