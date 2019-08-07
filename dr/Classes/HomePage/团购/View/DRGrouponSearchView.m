//
//  DRGrouponSearchView.m
//  dr
//
//  Created by 毛文豪 on 2017/10/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGrouponSearchView.h"
#import "DRGoodDetailViewController.h"
#import "DRGrouponTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRGrouponSearchView () <UITableViewDelegate, UITableViewDataSource, GrouponTableViewCellDelegate>

@property (nonatomic, assign) int pageIndex;//页数
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic,copy) NSString *keyWord;

@end


@implementation DRGrouponSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageIndex = 1;
        [self setupChildViews];
    }
    return self;
}

- (void)searchGrouponWithKeyword:(NSString *)keyWord
{
    self.keyWord = keyWord;
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.pageIndex),
                              @"pageSize":DRPageSize,
                              @"likeName":keyWord
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"S02",
                              };
    [MBProgressHUD showMessage:@"请稍后" toView:self];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self];
        if (SUCCESS) {
            //添加数据
            NSArray * dataArray = [DRGrouponModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self.dataArray addObjectsFromArray:dataArray];
            [self.tableView reloadData];
            //结束刷新
            [self.headerView endRefreshing];
            if (dataArray.count == 0) {
                [self.footerView endRefreshingWithNoMoreData];
            }else
            {
                [self.footerView endRefreshing];
            }
        }else
        {
            ShowErrorView
            //结束刷新
            [self.headerView endRefreshing];
            [self.footerView endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self];
        //结束刷新
        [self.headerView endRefreshing];
        [self.footerView endRefreshing];
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChildViews
{
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self addSubview:tableView];
    
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
}
#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self.dataArray removeAllObjects];
    [self searchGrouponWithKeyword:self.keyWord];
}
- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex ++;
    [self searchGrouponWithKeyword:self.keyWord];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"没有相关商品" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGrouponTableViewCell * cell = [DRGrouponTableViewCell cellWithTableView:tableView];
    cell.model = self.dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 9 + 129;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    DRGrouponModel *grouponModel = self.dataArray[indexPath.row];
    goodDetailVC.grouponId = grouponModel.id;
    goodDetailVC.isGroupon = YES;
    [self.viewController.navigationController pushViewController:goodDetailVC animated:YES];
}
- (void)grouponTableViewCell:(DRGrouponTableViewCell *)cell joinGrouponButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
    DRGrouponModel *grouponModel = self.dataArray[indexPath.row];
    goodDetailVC.grouponId = grouponModel.id;
    goodDetailVC.isGroupon = YES;
    [self.viewController.navigationController pushViewController:goodDetailVC animated:YES];
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
