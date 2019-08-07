//
//  DRChooseRedPacketViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/1/31.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRChooseRedPacketViewController.h"
#import "DRRedPacketTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRChooseRedPacketViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;

@end

@implementation DRChooseRedPacketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择红包";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(1),
                              @"pageSize":@"100000",
                              @"status":@(1),
                              @"orderPrice":@(self.orderPrice * 100),
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"C02",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * redPacketList = [DRRedPacketModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRRedPacketModel * redPacketModel in redPacketList) {
                if ([redPacketModel.coupon.minAmount doubleValue] <= self.orderPrice * 100) {
                    [self.dataArray addObject:redPacketModel];
                }
            }
            [self.tableView reloadData];//刷新数据
        }else
        {
            ShowErrorView
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
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消使用" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarDidClick)];
    
    //tableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStyleGrouped];
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
    
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    //清空数据
    [self.dataArray removeAllObjects];
    //请求数据
    [self getData];
}

- (void)cancelBarDidClick
{
    self.couponUserId = nil;
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(cancelRedPacket)]) {
        [_delegate cancelRedPacket];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView showNoDataWithTitle:@"" description:@"暂无可用红包" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRRedPacketTableViewCell *cell = [DRRedPacketTableViewCell cellWithTableView:tableView];
    DRRedPacketModel * redPacketModel = self.dataArray[indexPath.section];
    cell.customSelected = [redPacketModel.couponUser.id isEqualToString:self.couponUserId];
    cell.redPacketModel = redPacketModel;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRRedPacketModel * redPacketModel = self.dataArray[indexPath.section];
    self.couponUserId = redPacketModel.couponUser.id;
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(didChooseRedPacket:)]) {
        [_delegate didChooseRedPacket:redPacketModel];
    }
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
