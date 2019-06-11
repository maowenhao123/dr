//
//  DRPraiseAwardLogisticsViewController.m
//  dr
//
//  Created by 毛文豪 on 2019/1/8.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRPraiseAwardLogisticsViewController.h"
#import "DRSellerLogisticsTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRPraiseAwardLogisticsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;

@end

@implementation DRPraiseAwardLogisticsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"物流";
    [self setupChilds];
    waitingView
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
//    self.receiveId = @"190108115616010001";
    NSDictionary *bodyDic = @{
                              @"receiveId":self.receiveId
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G10",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.headerView endRefreshing];
        DRLog(@"%@", json);
        if (SUCCESS) {
            if ([json[@"status"] intValue] == 0) {
                self.dataArray = [NSArray array];
            }else
            {
                self.dataArray = [DRLogisticsTraceModel mj_objectArrayWithKeyValuesArray:json[@"traces"]];
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        [self.headerView endRefreshing];
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - [DRTool getSafeAreaBottom]) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    [DRTool setRefreshHeaderData:headerView];
    self.headerView = headerView;
    tableView.mj_header = headerView;
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    //清空数据
    self.dataArray = [NSArray array];
    //请求数据
    [self getData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"您的多肉还未发货，请稍后关注" isCar:NO rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSellerLogisticsTableViewCell * cell = [DRSellerLogisticsTableViewCell cellWithTableView:tableView];
    DRLogisticsTraceModel * traceModel = self.dataArray[indexPath.row];
    traceModel.isFirst = NO;
    traceModel.isLast = NO;
    if (traceModel == self.dataArray.firstObject) {
        traceModel.isFirst = YES;
    }
    if (traceModel == self.dataArray.lastObject) {
        traceModel.isLast = YES;
    }
    cell.logisticsTraceModel = traceModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRLogisticsTraceModel * traceModel = self.dataArray[indexPath.row];
    return traceModel.cellH;
}

#pragma mark - 初始化
- (NSArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

@end
