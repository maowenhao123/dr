//
//  DRSeckillGoodListViewController.m
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRSeckillGoodListViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRAddSeckillGoodViewController.h"
#import "DRSeckillGoodTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRSeckillGoodListViewController ()<UITableViewDataSource, UITableViewDelegate, AddSeckillGoodDelegate, SeckillGoodTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;//页数

@end

@implementation DRSeckillGoodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"十点秒杀";
    [self setupChilds];
    self.pageIndex = 1;
    waitingView;
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              @"id": self.activityId,
                              @"pageIndex": @(self.pageIndex),
                              @"pageSize": DRPageSize,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G14",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray *activityList = [DRSeckillGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:activityList];
            [self.tableView reloadData];//刷新数据
            if (activityList.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            [self.footerView endRefreshing];
        }
        //结束刷新
        [self.headerView endRefreshing];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加商品
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"+添加商品" style:UIBarButtonItemStylePlain target:self action:@selector(addGoodDidClick)];
    
    //tableview
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)];
    headerView.backgroundColor = DRBackgroundColor;
    tableView.tableHeaderView = headerView;
    
    //初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    self.headerView = headerRefreshView;
    [DRTool setRefreshHeaderData:headerRefreshView];
    tableView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    self.footerView = footerView;
    [DRTool setRefreshFooterData:footerView];
    tableView.mj_footer = footerView;
}

- (void)addGoodDidClick
{
    DRAddSeckillGoodViewController * addSeckillGoodVC = [[DRAddSeckillGoodViewController  alloc]init];
    addSeckillGoodVC.activityId = self.activityId;
    addSeckillGoodVC.delegate = self;
    [self.navigationController pushViewController:addSeckillGoodVC animated:YES];
}

- (void)addSeckillGoodSuccess
{
    [self headerRefreshViewBeginRefreshing];
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
    [tableView showNoDataWithTitle:@"" description:@"暂无商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRSeckillGoodTableViewCell *cell = [DRSeckillGoodTableViewCell cellWithTableView:tableView];
    cell.seckillGoodModel = self.dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    DRSeckillGoodModel * seckillGoodModel = self.dataArray[indexPath.row];
    goodVC.goodId = seckillGoodModel.id;
    [self.navigationController pushViewController:goodVC animated:YES];
}

- (void)seckillGoodTableViewCell:(DRSeckillGoodTableViewCell *)cell buttonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    DRSeckillGoodModel * seckillGoodModel = self.dataArray[indexPath.row];
    if ([button.currentTitle isEqualToString:@"下架"]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认下架该商品?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:button.currentTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *bodyDic = @{
                                      @"id":seckillGoodModel.activityId,
                                      };
            
            NSDictionary *headDic = @{
                                      @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                      @"cmd":@"G18",
                                      @"userId":UserId,
                                      };
            [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
                DRLog(@"%@",json);
                if (SUCCESS) {
                    [self.dataArray removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }else
                {
                    ShowErrorView
                    
                }
            } failure:^(NSError *error) {
                DRLog(@"error:%@",error);
            }];
        }];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [self presentViewController:alertController animated:YES completion:nil];
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
