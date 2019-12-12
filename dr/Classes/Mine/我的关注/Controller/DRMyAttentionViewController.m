//
//  DRMyAttentionViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//
#import "DRMyAttentionViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRShopDetailViewController.h"
#import "DRUserShowViewController.h"
#import "DRMaintainDetailViewController.h"
#import "DRAttentionGoodTableViewCell.h"
#import "DRAttentionShopTableViewCell.h"
#import "DRAttentionShowTableViewCell.h"
#import "DRMaintainTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRMyAttentionViewController ()<UITableViewDataSource,UITableViewDelegate, AttentionShopTableViewCellDelegate, AttentionShowTableViewCellDelegate>

@property (nonatomic, assign) int pageIndex1;//全部的页数
@property (nonatomic, assign) int pageIndex2;//收入的页数
@property (nonatomic, assign) int pageIndex3;//支出的页数
@property (nonatomic, assign) int pageIndex4;//支出的页数
@property (nonatomic, assign) int currentPageIndex;//当前的页数
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;
@property (nonatomic,strong) NSMutableArray *attentionArray;

@end

@implementation DRMyAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的关注";
    self.currentPageIndex = 1;
    self.pageIndex1 = 1;
    self.pageIndex2 = 1;
    self.pageIndex3 = 1;
    self.pageIndex4 = 1;
    [self setupChilds];
}
#pragma mark - 请求数据
- (void)getData
{
    //type 类型，1 关注商品， 2 关注店铺 ，3玩家秀 ，4 关注帖子
    NSNumber * inType = [NSNumber numberWithInteger:self.currentIndex + 1];
    NSDictionary *bodyDic = @{
                              @"pageIndex":@(self.currentPageIndex),
                              @"pageSize":DRPageSize,
                              @"type":inType,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U24",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
            NSArray * newAttentionArray_ = [NSMutableArray array];
            newAttentionArray_ = json[@"list"];
            [attentionArray_ addObjectsFromArray:newAttentionArray_];
            [tableView reloadData];
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                if (newAttentionArray_.count == 0) {
                    [footerView endRefreshingWithNoMoreData];
                }else
                {
                    [footerView endRefreshing];
                }
            }
        }else
        {
            ShowErrorView
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                [footerView endRefreshing];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
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

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加4个btnTitle
    self.btnTitles = @[@"商品", @"店铺", @"用户", @"帖子"];
    //添加4个tableview
    CGFloat scrollViewH = screenHeight - statusBarH - navBarH - topBtnH;
    for(int i = 0;i < self.btnTitles.count; i++)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth * i, 0, screenWidth, scrollViewH)];
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
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    //没有数据时加载数据
    if(attentionArray_.count == 0)
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
    }else if(self.currentIndex == 2)
    {
        self.pageIndex3 = 1;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 = 1;
    }
    self.currentPageIndex = 1;
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    [attentionArray_ removeAllObjects];
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
    }else if(self.currentIndex == 2)
    {
        self.pageIndex3 += 1;
        self.currentPageIndex = self.pageIndex3;
    }else if(self.currentIndex == 3)
    {
        self.pageIndex4 += 1;
        self.currentPageIndex = self.pageIndex4;
    }
    [self getData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    if (tableView.tag == 0) {
        [tableView showNoDataWithTitle:@"" description:@"您还没有关注过商品" rowCount:attentionArray_.count];
    }else if (tableView.tag == 1)
    {
        [tableView showNoDataWithTitle:@"" description:@"您还没有关注过店铺" rowCount:attentionArray_.count];
    }else if (tableView.tag == 2)
    {
        [tableView showNoDataWithTitle:@"" description:@"您还没有关注过用户" rowCount:attentionArray_.count];
    }else
    {
        [tableView showNoDataWithTitle:@"" description:@"您还没有关注过帖子" rowCount:attentionArray_.count];
    }
    return attentionArray_.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    if (self.currentIndex == 0) {
        DRAttentionGoodTableViewCell *cell = [DRAttentionGoodTableViewCell cellWithTableView:tableView];
        cell.json = attentionArray_[indexPath.row];
        return cell;
    }else if (self.currentIndex == 1)
    {
        DRAttentionShopTableViewCell *cell = [DRAttentionShopTableViewCell cellWithTableView:tableView];
        cell.json = attentionArray_[indexPath.row];
        cell.delegate = self;
        return cell;
    }else if (self.currentIndex == 2)
    {
        DRAttentionShowTableViewCell *cell = [DRAttentionShowTableViewCell cellWithTableView:tableView];
        cell.json = attentionArray_[indexPath.row];
        cell.delegate = self;
        return cell;
    }else
    {
        DRMaintainTableViewCell *cell = [DRMaintainTableViewCell cellWithTableView:tableView];
        id json = attentionArray_[indexPath.row];
        cell.dic = json[@"article"];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentIndex == 0) {
        return 104 + 1;
    }else if (self.currentIndex == 1)
    {
        CGFloat padding = 5;
        CGFloat smallImageViewWH = (screenWidth -  4 * padding) / 3;
        return 53 + padding * 2 + smallImageViewWH * 2 + 44;
    }else if (self.currentIndex == 2)
    {
        return 1 + 50;
    }
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    if (self.currentIndex == 0) {
        DRGoodDetailViewController * goodDetailVC = [[DRGoodDetailViewController alloc] init];
        NSDictionary * dic = attentionArray_[indexPath.row];
        goodDetailVC.goodId = dic[@"goods"][@"id"];
        [self.navigationController pushViewController:goodDetailVC animated:YES];
    }else if (self.currentIndex == 1)
    {
        
    }else if (self.currentIndex == 2)
    {
        NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
        id json = attentionArray_[indexPath.row];
  
        DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
        showDetailVC.userId = json[@"user"][@"id"];
        if (DRStringIsEmpty(json[@"user"][@"nickName"])) {
            showDetailVC.nickName = json[@"user"][@"loginName"];
        }else
        {
            showDetailVC.nickName = json[@"user"][@"nickName"];
        }
        showDetailVC.userHeadImg = json[@"user"][@"headImg"];
        [self.navigationController pushViewController:showDetailVC animated:YES];
    }else
    {
        NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
        id json = attentionArray_[indexPath.row];
        
        DRMaintainDetailViewController * maintainDetailVC = [[DRMaintainDetailViewController alloc] init];
        maintainDetailVC.maintainId = json[@"article"][@"id"];
        maintainDetailVC.dic = json[@"article"];
        [self.navigationController pushViewController:maintainDetailVC animated:YES];
    }
    
}
#pragma mark - 协议
- (void)attentionShopTableViewCell:(UITableViewCell *)cell cancelAttentionButtonDidClick:(UIButton *)button
{
    UITableView *tableView = self.views[self.currentIndex];
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    id json = attentionArray_[indexPath.row];
    
    NSDictionary *bodyDic = @{
                              @"id":json[@"store"][@"id"],
                              @"type":@(2)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U23",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [attentionArray_ removeObjectAtIndex:indexPath.row];
            if (attentionArray_.count == 0) {
                [tableView reloadData];
            }else
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)attentionShopTableViewCell:(UITableViewCell *)cell goshopButtonDidClick:(UIButton *)button
{
    UITableView *tableView = self.views[self.currentIndex];
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    id json = attentionArray_[indexPath.row];
    DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
    shopVC.shopId = json[@"store"][@"id"];
    [self.navigationController pushViewController:shopVC animated:YES];
}
- (void)attentionShopTableViewCell:(UITableViewCell *)cell goGoodWithGoodId:(NSString *)goodId
{
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    goodVC.goodId = goodId;
    [self.navigationController pushViewController:goodVC animated:YES];
}
- (void)attentionShowTableViewCell:(UITableViewCell *)cell cancelAttentionButtonDidClick:(UIButton *)button
{
    UITableView *tableView = self.views[self.currentIndex];
    NSMutableArray * attentionArray_ = self.attentionArray[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    id json = attentionArray_[indexPath.row];
    
    NSDictionary *bodyDic = @{
                              @"id":json[@"user"][@"id"],
                              @"type":@(3)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U23",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [attentionArray_ removeObjectAtIndex:indexPath.row];
            if (attentionArray_.count == 0) {
                [tableView reloadData];
            }else
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
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
- (NSMutableArray *)attentionArray
{
    if(_attentionArray == nil)
    {
        _attentionArray = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            NSMutableArray * array = [NSMutableArray array];
            [_attentionArray addObject:array];
        }
    }
    return _attentionArray;
}

@end
