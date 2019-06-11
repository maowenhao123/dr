//
//  DRMaintainViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/12.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMaintainViewController.h"
#import "DRMaintainDetailViewController.h"
#import "DRMaintainTableViewCell.h"

@interface DRMaintainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSArray * sortArray;//分类
@property (nonatomic, strong) NSMutableDictionary * dataDic;//分类=
@property (nonatomic, strong) NSMutableDictionary * pageIndexDic;//页数的字典
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;

@end

@implementation DRMaintainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"养护知识";
    [self getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:@"MaintainReadNotification" object:nil];
}

- (void)getData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"P10",
                              };
    waitingView;
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * sortArray = json[@"list"];
            NSMutableArray *sortArray_ = [NSMutableArray arrayWithArray:sortArray];
            [sortArray_ insertObject:@{@"name":@"全部",@"id":@"0"} atIndex:0];
            self.sortArray = [NSArray arrayWithArray:sortArray_];
            [self setupChilds];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)getListData
{
    NSString * categoryId = self.sortArray[self.currentIndex][@"id"];
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    NSNumber * pageIndex = self.pageIndexDic[sortDic[@"id"]];
    int pageIndexInt = [pageIndex intValue];
    pageIndexInt = pageIndexInt == 0 ? 1 : pageIndexInt;
    NSDictionary *bodyDic_ = @{
                              @"pageIndex":@(pageIndexInt),
                              @"pageSize":DRPageSize,
                              };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    NSString * name = self.sortArray[self.currentIndex][@"name"];
    if (![categoryId isEqualToString:@"0"] && ![name isEqualToString:@"全部"] && !DRStringIsEmpty(categoryId)) {
        //不传categoryId获取全部
        [bodyDic setObject:categoryId forKey:@"categoryId"];
    }
    
    NSDictionary *headDic = @{
                              @"cmd":@"P11",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            //添加数据
            NSArray * dataArray_ = json[@"list"];
            NSMutableArray * dataArray = self.dataDic[categoryId];
            if (DRArrayIsEmpty(dataArray)) {
                dataArray = [NSMutableArray array];
            }
            [dataArray addObjectsFromArray:dataArray_];
            [self.dataDic setValue:dataArray forKey:categoryId];
            [tableView reloadData];
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                if (dataArray_.count == 0) {
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
    //添加3个btnTitle
    NSMutableArray *btnTitles = [NSMutableArray array];
    for (NSDictionary * dic in self.sortArray) {
        [btnTitles addObject:dic[@"name"]];
    }
    self.btnTitles = btnTitles;
    //添加tableview
    CGFloat scrollViewH = screenHeight-statusBarH-navBarH-topBtnH;
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
        
        //headerView
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
        headerView.backgroundColor = DRBackgroundColor;
        tableView.tableHeaderView = headerView;
        
        //初始化头部刷新控件
        MJRefreshGifHeader *headerRefreshView = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
        [DRTool setRefreshHeaderData:headerRefreshView];
        [self.headerViews addObject:headerRefreshView];
        tableView.mj_header = headerRefreshView;
        
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
    NSDictionary * sortDic = self.sortArray[currentIndex];
    NSArray * dataArray = self.dataDic[sortDic[@"id"]];
    if (DRArrayIsEmpty(dataArray)) {
        [self getListData];
    }
}
#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    [self.dataDic setValue:[NSMutableArray array] forKey:sortDic[@"id"]];
    
    [self.pageIndexDic setValue:[NSNumber numberWithInt:1] forKey:sortDic[@"id"]];
    [self getListData];
}
- (void)footerRefreshViewBeginRefreshing
{
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    NSNumber * pageIndex = self.pageIndexDic[sortDic[@"id"]];
    int pageIndexInt = [pageIndex intValue];
    pageIndexInt = pageIndexInt == 0 ? 1 : pageIndexInt;
    pageIndexInt++;
    [self.pageIndexDic setValue:[NSNumber numberWithInt:pageIndexInt] forKey:sortDic[@"id"]];
    [self getListData];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    NSArray * dataArray = self.dataDic[sortDic[@"id"]];
    return dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMaintainTableViewCell *cell = [DRMaintainTableViewCell cellWithTableView:tableView];
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    NSArray * dataArray = self.dataDic[sortDic[@"id"]];
    cell.dic = dataArray[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMaintainDetailViewController * maintainVC = [[DRMaintainDetailViewController alloc] init];
    NSDictionary * sortDic = self.sortArray[self.currentIndex];
    NSArray * dataArray = self.dataDic[sortDic[@"id"]];
    NSDictionary * dic = dataArray[indexPath.row];
    maintainVC.maintainId = dic[@"id"];
    maintainVC.dic = dic;
    [self.navigationController pushViewController:maintainVC animated:YES];
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

- (NSArray *)sortArray
{
    if (!_sortArray) {
        _sortArray = [NSArray array];
    }
    return _sortArray;
}
- (NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return _dataDic;
}
- (NSMutableDictionary *)pageIndexDic
{
    if (!_pageIndexDic) {
        _pageIndexDic = [NSMutableDictionary dictionary];
    }
    return _pageIndexDic;
}

@end
