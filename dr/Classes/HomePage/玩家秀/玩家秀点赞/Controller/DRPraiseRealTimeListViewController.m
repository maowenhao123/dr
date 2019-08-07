//
//  DRRealTimePraiseListViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/18.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseRealTimeListViewController.h"
#import "DRLoginViewController.h"
#import "DRShowDetailViewController.h"
#import "DRPraiseListTableViewCell.h"
#import "DRPraiseSectionModel.h"
#import "UITableView+DRNoData.h"

@interface DRPraiseRealTimeListViewController ()<UITableViewDataSource, UITableViewDelegate, PraiseListTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, assign) int pageIndex1;
@property (nonatomic, assign) int pageIndex2;
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;

@end

@implementation DRPraiseRealTimeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"实时榜单";
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.currentPageIndex = 1;
    [self setupChilds];
}

#pragma mark - 请求数据
- (void)getData
{
    /*
     type=1 按时间查询
     type=2 点赞数最多
     type=3 活动期间周点赞排名
     type=4 活动期间总点赞排名*/
    NSString *cmd = @"";
    NSNumber *type = @(0);
    if (self.currentIndex == 0) {
        cmd = @"A03";
        type = @(3);
    }else if (self.currentIndex == 1)
    {
        cmd = @"A03";
        type = @(4);
    }
    NSDictionary *bodyDic = @{
                               @"pageIndex":@(self.currentPageIndex),
                               @"pageSize":DRPageSize,
                               @"type":type,
                               };
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSArray *praiseList = [DRPraiseModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSMutableArray *oldPraiseList = self.dataArray[self.currentIndex];
            DRPraiseSectionModel * praiseSectionModel = oldPraiseList.firstObject;
            [praiseSectionModel.praiseList addObjectsFromArray:praiseList];
            [tableView reloadData];//刷新数据
            if (praiseList.count == 0) {//没有新的数据
                [footerView endRefreshingWithNoMoreData];
            }else
            {
                [footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            [footerView endRefreshing];
        }
        //结束刷新
        [headerView endRefreshing];
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        //结束刷新
        [headerView endRefreshing];
        [footerView endRefreshing];
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.btnTitles = @[@"周榜", @"总榜"];
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
    //没有数据时加载数据
    if([self getDataCount] == 0)
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
    }
    self.currentPageIndex = 1;
    //清空数据
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList.firstObject;
    [praiseSectionModel.praiseList removeAllObjects];
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
    }
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList.firstObject;
    [tableView showNoDataWithTitle:@"" description:@"暂无数据" rowCount:praiseSectionModel.praiseList.count];
    return praiseSectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList[section];
    return praiseSectionModel.praiseList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRPraiseListTableViewCell *cell = [DRPraiseListTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.index = indexPath.row;
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList[indexPath.section];
    cell.praiseModel = praiseSectionModel.praiseList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DRShowDetailViewController * showDetailVC = [[DRShowDetailViewController alloc] init];
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList[indexPath.section];
    DRPraiseModel *praiseModel = praiseSectionModel.praiseList[indexPath.row];
    showDetailVC.showId = praiseModel.id;
    [self.navigationController pushViewController:showDetailVC animated:YES];
}

- (void)praiseListTableViewCellPraiseButtonDidClickWithCell:(DRPraiseListTableViewCell *)cell
{
    UITableView * tableView = self.views[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList[indexPath.section];
    DRPraiseModel *praiseModel = praiseSectionModel.praiseList[indexPath.row];
    NSString * cmd;
    if ([praiseModel.focus boolValue]) {//取消关注
        cmd = @"U23";
    }else//添加关注
    {
        cmd = @"U22";
    }
    NSDictionary *bodyDic = @{
                              @"id":praiseModel.userId,
                              @"type":@(3)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            praiseModel.focus = @(![praiseModel.focus boolValue]);
            UITableView *tableView = self.views[self.currentIndex];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
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
            DRPraiseSectionModel * praiseSectionModel = [[DRPraiseSectionModel alloc] init];
            [array addObject:praiseSectionModel];
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

- (NSMutableArray *)footerViews
{
    if(_footerViews == nil)
    {
        _footerViews = [NSMutableArray array];
    }
    return _footerViews;
}

#pragma mark - 工具
//计算当前的数据数
- (int)getDataCount
{
    NSMutableArray *praiseSectionList = self.dataArray[self.currentIndex];
    DRPraiseSectionModel * praiseSectionModel = praiseSectionList.firstObject;
    return (int)praiseSectionModel.praiseList.count;
}


@end
