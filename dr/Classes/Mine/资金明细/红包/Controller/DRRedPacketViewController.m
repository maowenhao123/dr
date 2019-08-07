//
//  DRRedPacketViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/8/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRRedPacketViewController.h"
#import "DRRedPacketTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRRedPacketViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray *headerViews;

@end

@implementation DRRedPacketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"红包";
    [self setupChilds];
}

#pragma mark - 请求数据
- (void)getData
{
    //status 1 未使用 2 已使用 3 已过期
    NSNumber * status = [NSNumber numberWithInteger:self.currentIndex + 1];
    NSDictionary *bodyDic = @{
                              @"status":status,
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
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray *oldRedPacketList = self.dataArray[self.currentIndex];
            NSArray *redPacketList = [DRRedPacketModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [oldRedPacketList addObjectsFromArray:redPacketList];
            [tableView reloadData];//刷新数据
        }else
        {
            ShowErrorView
        }
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加3个btnTitle
    self.btnTitles = @[@"未使用", @"已使用", @"已过期"];
    //添加3个tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0; i < self.btnTitles.count; i++)
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
    NSMutableArray *redPacketList = self.dataArray[self.currentIndex];
    [redPacketList removeAllObjects];
    //请求数据
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *redPacketList = self.dataArray[self.currentIndex];
    NSArray * btnTitles = @[@"未使用", @"已使用", @"已过期"];
    NSString *description = [NSString stringWithFormat:@"暂无%@红包", btnTitles[self.currentIndex]];
    [tableView showNoDataWithTitle:@"" description:description rowCount:redPacketList.count];
    return redPacketList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRRedPacketTableViewCell *cell = [DRRedPacketTableViewCell cellWithTableView:tableView];
    NSMutableArray *redPacketList = self.dataArray[self.currentIndex];
    cell.index = self.currentIndex + 1;
    cell.redPacketModel = redPacketList[indexPath.section];
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

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if(_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
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
    NSMutableArray *redPacketList = self.dataArray[self.currentIndex];
    return (int)redPacketList.count;
}

@end
