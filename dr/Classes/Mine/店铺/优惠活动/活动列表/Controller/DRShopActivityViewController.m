//
//  DRShopActivityViewController.m
//  dr
//
//  Created by 毛文豪 on 2019/1/17.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRShopActivityViewController.h"
#import "DRSeckillGoodListViewController.h"
#import "DRActivityTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRShopActivityViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray *headerViews;

@end

@implementation DRShopActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"活动管理";
    [self setupChilds];
    [self getData];
    waitingView
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G13",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        if (SUCCESS) {
            UITableView *tableView = self.views[self.currentIndex];
            NSArray *activityList = [DRShopActivityModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            NSMutableArray *oldActivityList = self.dataArray[self.currentIndex];
            [oldActivityList addObjectsFromArray:activityList];
            [tableView reloadData];//刷新数据
        }else
        {
            ShowErrorView
        }
        //结束刷新
        [headerView endRefreshing];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        [headerView endRefreshing];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加2个btnTitle
    self.btnTitles = @[@"平台活动", @"店铺活动"];
    //添加2个tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0;i < self.btnTitles.count; i++)
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
    }
    //完成配置
    [super configurationComplete];
    [super topBtnClick:self.topBtns[self.currentIndex]];
}

#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    //清空数据
    NSMutableArray *activityList = self.dataArray[self.currentIndex];
    [activityList removeAllObjects];
    //请求数据
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray * activityArray = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"暂无活动" rowCount:activityArray.count];
    return activityArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRActivityTableViewCell *cell = [DRActivityTableViewCell cellWithTableView:tableView];
    NSMutableArray * activityArray = self.dataArray[self.currentIndex];
    cell.activityModel = activityArray[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
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

@end
