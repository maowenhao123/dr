//
//  DRReturnGoodManageViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodManageViewController.h"
#import "DRReturnGoodHandleViewController.h"
#import "DRReturnGoodDetailViewController.h"
#import "DRReturnGoodManageTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRReturnGoodManageViewController ()<UITableViewDataSource,UITableViewDelegate, ReturnGoodManageTableViewCellDelegate>

@property (nonatomic, assign) int pageIndex1;//全部的页数
@property (nonatomic, assign) int pageIndex2;//收入的页数
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRReturnGoodManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"退款管理";
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.currentPageIndex = 1;
    [self setupChilds];
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"ReturnGoodHandleSuccess" object:nil];
}
- (void)getData
{
    NSNumber *status;
    if (self.currentIndex == 0) {//待处理
        status = @(10);
    }else if (self.currentIndex == 1) {//已处理
        status = @(101);
    }
    
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.currentPageIndex),
                              @"pageSize":DRPageSize,
                              @"status":status,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S26",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
            NSArray * newDataArray_ = [DRReturnGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [dataArray_ addObjectsFromArray:newDataArray_];
            [tableView reloadData];
            if (newDataArray_.count == 0) {//没有新的数据
                [footerView endRefreshingWithNoMoreData];
            }else
            {
                [footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
        }
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        //结束刷新
        if ([headerView isRefreshing]) {
            [headerView endRefreshing];
        }
        if ([footerView isRefreshing]) {
            [footerView endRefreshing];
        }
    }];
}
- (void)setupChilds
{
    //添加btnTitle
    self.btnTitles = @[@"待处理",@"已处理"];
    //添加tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0;i < self.btnTitles.count;i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH)];
        tableView.tag = i;
        tableView.backgroundColor = DRBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
        [self.views addObject:tableView];
        
        UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        tableHeaderView.backgroundColor = DRBackgroundColor;
        tableView.tableHeaderView = tableHeaderView;

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
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    //没有数据时加载数据
    if(dataArray_.count == 0)
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
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    [dataArray_ removeAllObjects];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"您还没有相关的订单" rowCount:dataArray_.count];
    return dataArray_.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DRReturnGoodManageTableViewCell *cell = [DRReturnGoodManageTableViewCell cellWithTableView:tableView];
    cell.returnGoodModel = dataArray_[indexPath.row];
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DRReturnGoodModel * returnGoodModel = dataArray_[indexPath.row];
    if (self.currentIndex == 0 && [returnGoodModel.status intValue] == 10) {
        DRReturnGoodHandleViewController * returnGoodVC = [[DRReturnGoodHandleViewController alloc] init];
        returnGoodVC.returnGoodId = returnGoodModel.id;
        if (!DRObjectIsEmpty(returnGoodModel.specification)) {
            returnGoodVC.specificationId = returnGoodModel.specification.id;
        }
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }else
    {
        DRReturnGoodDetailViewController * returnGoodVC = [[DRReturnGoodDetailViewController alloc] init];
        returnGoodVC.returnGoodId = returnGoodModel.id;
        if (!DRObjectIsEmpty(returnGoodModel.specification)) {
            returnGoodVC.specificationId = returnGoodModel.specification.id;
        }
        returnGoodVC.isSeller = YES;
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }
}
- (void)returnGoodManageTableViewCell:(DRReturnGoodManageTableViewCell *)cell buttonDidClick:(UIButton *)button
{
    UITableView *tableView = self.views[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    
    NSMutableArray * dataArray_ = self.dataArray[self.currentIndex];
    DRReturnGoodModel * returnGoodModel = dataArray_[indexPath.row];
    if (self.currentIndex == 0 && [returnGoodModel.status intValue] == 10) {
        DRReturnGoodHandleViewController * returnGoodVC = [[DRReturnGoodHandleViewController alloc] init];
        returnGoodVC.returnGoodId = returnGoodModel.id;
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }
}
#pragma mark - 初始化
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
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_dataArray addObject:array];
        }
    }
    return _dataArray;
}


@end
