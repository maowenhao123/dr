//
//  DRPraiseMyAwardViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseMyAwardViewController.h"
#import "DRPraiseAwardLogisticsViewController.h"
#import "DRPraiseGoodAwardViewController.h"
#import "DRRedPacketViewController.h"
#import "DRLoginViewController.h"
#import "DRPraiseMyAwardTableViewCell.h"
#import "DRPraiseSectionModel.h"
#import "UITableView+DRNoData.h"

@interface DRPraiseMyAwardViewController ()<UITableViewDataSource, UITableViewDelegate, PraiseMyAwardTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, assign) long long systemTime;

@end

@implementation DRPraiseMyAwardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"实时榜单";
    [self setupChilds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"PraiseAwardGoodSuccess" object:nil];
}

#pragma mark - 请求数据
- (void)getData
{
    NSString *cmd = @"";
    if (self.currentIndex == 0) {
        cmd = @"G03";
    }else if (self.currentIndex == 1)
    {
        cmd = @"G08";
    }
    NSDictionary *bodyDic = @{
                              };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            if (self.currentIndex == 0) {
                self.systemTime = [json[@"systemTime"] longLongValue];
                NSArray *awardSectionList = [DRPraiseSectionModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
                for (DRPraiseSectionModel * awardSectionModel in awardSectionList) {
                    awardSectionModel.type = @(1);
                    NSInteger index = [awardSectionList indexOfObject:awardSectionModel];
                    NSArray *awardList = [DRAwardModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"activityList"]];
                    awardSectionModel.awardList = [NSMutableArray arrayWithArray:awardList];
                }
                NSMutableArray *oldAwardList = self.dataArray[self.currentIndex];
                [oldAwardList addObjectsFromArray:awardSectionList];
            }else
            {
                DRPraiseSectionModel *awardSectionModel = [DRPraiseSectionModel mj_objectWithKeyValues:json];
                awardSectionModel.type = @(2);
                NSArray *awardList = [DRAwardModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
                [awardSectionModel.awardList addObjectsFromArray:awardList];
                NSMutableArray *oldAwardList = self.dataArray[self.currentIndex];
                [oldAwardList removeAllObjects];
                [oldAwardList addObject:awardSectionModel];
            }
            [tableView reloadData];//刷新数据
        }else
        {
            ShowErrorView
        }
        //结束刷新
        [headerView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        //结束刷新
        [headerView endRefreshing];
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    self.btnTitles = @[@"周奖励", @"总奖励"];
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH - 45 - [DRTool getSafeAreaBottom];
    for(int i = 0; i < self.btnTitles.count; i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH)];
        tableView.tag = i;
        tableView.backgroundColor = DRBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
        tableView.tableFooterView = [UIView new];
        [self.views addObject:tableView];
        
        //初始化头部刷新控件
        MJRefreshGifHeader *headerView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
        [DRTool setRefreshHeaderData:headerView];
        [self.headerViews addObject:headerView];
        tableView.mj_header = headerView;
    }
    
    //完成配置
    [super configurationComplete];
    [super topBtnClick:self.topBtns[self.currentIndex]];
}

- (void)changeCurrentIndex:(int)currentIndex
{
    //没有数据时加载数据
    if([self getDataCount] == 0)
    {
        [self getData];
    }
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    //清空数据
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    [praiseSectionList removeAllObjects];
    //请求数据
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *awardSectionList = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"您还没有相关的记录" rowCount:awardSectionList.count];
    
    return awardSectionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRPraiseMyAwardTableViewCell *cell = [DRPraiseMyAwardTableViewCell cellWithTableView:tableView];
    NSMutableArray *awardSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * awardSectionModel = awardSectionList[indexPath.item];
    cell.systemTime = self.systemTime;
    cell.awardSectionModel = awardSectionModel;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *awardSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * awardSectionModel = awardSectionList[indexPath.item];
    return awardSectionModel.cellH;
}

- (void)praiseMyAwardTableViewCell:(DRPraiseMyAwardTableViewCell *)cell awardButtonDidClick:(UIButton *)button
{
    UITableView * tableView = self.views[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    NSMutableArray *awardSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * awardSectionModel = awardSectionList[indexPath.row];
    DRAwardModel *awardModel = awardSectionModel.awardList.firstObject;
    
    if (button.tag == 0) {
        if ([button.currentTitle isEqualToString:@"查看"]) {
            DRRedPacketViewController * redPacketVC = [[DRRedPacketViewController alloc] init];
            [self.navigationController pushViewController:redPacketVC animated:YES];
        }else
        {
            [self drawRedPacketWithAwardModel:awardModel indexPath:indexPath];
        }
    }else
    {
        if ([button.currentTitle isEqualToString:@"查物流"]) {
            DRPraiseAwardLogisticsViewController * logisticsVC = [[DRPraiseAwardLogisticsViewController alloc] init];
            logisticsVC.receiveId = awardModel.receiveId;
            [self.navigationController pushViewController:logisticsVC animated:YES];
        }else
        {
            DRPraiseGoodAwardViewController * goodAwardVC = [[DRPraiseGoodAwardViewController alloc] init];
            goodAwardVC.type = awardModel.type;
            goodAwardVC.activityId = awardModel.id;
            [self.navigationController pushViewController:goodAwardVC animated:YES];
        }
    }
}

- (void)drawRedPacketWithAwardModel:(DRAwardModel *)awardModel indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *bodyDic = @{
                              @"activityId": awardModel.id,
                              @"receiveType": @(2),
                              @"type": awardModel.type
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G05",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"领取成功"];
            awardModel.receiveType = @(2);
            awardModel.status = @(1);
            UITableView *tableView = self.views[self.currentIndex];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}

- (NSMutableArray *)headerViews
{
    if(_headerViews == nil)
    {
        _headerViews = [NSMutableArray array];
    }
    return _headerViews;
}

#pragma mark - 工具
//计算当前的数据数
- (int)getDataCount
{
    NSMutableArray *awardList = self.dataArray[self.currentIndex];
    return (int)awardList.count;
}

@end
