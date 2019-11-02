//
//  DRReturnGoodListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodListViewController.h"
#import "DRReturnGoodViewController.h"
#import "DRReturnGoodDetailViewController.h"
#import "DRReturnGoodTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRReturnGoodListViewController ()<UITableViewDelegate, UITableViewDataSource, ReturnGoodTableViewCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic,weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;//页数

@end

@implementation DRReturnGoodListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"退款";
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"returnGoodSuccess" object:nil];
    self.pageIndex = 1;
    [self getData];
    [self setupChilds];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic_ = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                               };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    NSString *cmd = @"S25";
    if (!DRStringIsEmpty(self.orderId)) {
        [bodyDic setObject:self.orderId forKey:@"orderId"];
        cmd = @"S30";
    }

    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray *dataArray = [DRReturnGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArray];
            [self.tableView reloadData];
            if ([self.footerView isRefreshing]) {
                if (dataArray.count == 0) {
                    [self.footerView endRefreshingWithNoMoreData];
                }else
                {
                    [self.footerView endRefreshing];
                }
            }
            [self.tableView reloadData];
        }else
        {
            ShowErrorView
            if ([self.footerView isRefreshing]) {
                [self.footerView endRefreshing];
            }
        }
        if ([self.headerView isRefreshing]) {
            [self.headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);//结束刷新
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
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];//初始化头部刷新控件
    MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    [DRTool setRefreshHeaderData:headerRefreshView];
    self.headerView = headerRefreshView;
    tableView.mj_header = headerRefreshView;
    
    //初始化底部刷新控件
    MJRefreshBackGifFooter *footerView = [MJRefreshBackGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshViewBeginRefreshing)];
    [DRTool setRefreshFooterData:footerView];
    self.footerView = footerView;
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

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"您还没有相关的订单" description:@"去买个多肉萌翻自己~" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRReturnGoodTableViewCell * cell = [DRReturnGoodTableViewCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.returnGoodModel = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 9 + 35 + 100 + 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRReturnGoodModel * returnGoodModel = self.dataArray[indexPath.row];
    if ([returnGoodModel.status intValue] != 0) {
        DRReturnGoodDetailViewController * returnGoodVC = [[DRReturnGoodDetailViewController alloc] init];
        returnGoodVC.returnGoodId = returnGoodModel.id;
        if (!DRObjectIsEmpty(returnGoodModel.specification)) {
            returnGoodVC.specificationId = returnGoodModel.specification.id;
        }
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }else
    {
        DRReturnGoodViewController * returnGoodVC = [[DRReturnGoodViewController alloc] init];
        returnGoodVC.commentGoodModel = self.dataArray[indexPath.row];
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }
}

- (void)returnGoodTableViewCell:(DRReturnGoodTableViewCell *)cell returnGoodButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRReturnGoodModel * returnGoodModel = self.dataArray[indexPath.row];
    if ([returnGoodModel.status intValue] == 0) {
        DRReturnGoodViewController * returnGoodVC = [[DRReturnGoodViewController alloc] init];
        returnGoodVC.commentGoodModel = self.dataArray[indexPath.row];
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }
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
