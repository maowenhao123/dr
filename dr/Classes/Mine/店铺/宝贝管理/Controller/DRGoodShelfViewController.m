//
//  DRGoodShelfViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodShelfViewController.h"
#import "DRMailSettingViewController.h"
#import "DRGoodDetailViewController.h"
#import "DRPublishGoodViewController.h"
#import "DRGoodShelfTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRGoodShelfViewController ()<UITableViewDataSource,UITableViewDelegate, GoodShelfTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableDictionary * pageIndexDic;//页数的字典
@property (nonatomic, strong) NSMutableArray *headerViews;
@property (nonatomic, strong) NSMutableArray *footerViews;

@end

@implementation DRGoodShelfViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的货架";
    [self setupChilds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGoodSuccess) name:@"addGoodSuccess" object:nil];
}
- (void)addGoodSuccess
{
    NSMutableArray *dataArray_ = self.dataArray[0];
    [dataArray_ removeAllObjects];
    [super topBtnClick:self.topBtns[0]];//审核中页面
}
- (void)getData
{
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    NSString * storeId = myShopModel.id;
    if (DRStringIsEmpty(storeId)) {
        return;
    }
    NSNumber *status;
    if (self.currentIndex == 0) {
        status = @(1);
    }else if (self.currentIndex == 1) {
        status = @(0);
    }else if (self.currentIndex == 2) {
        status = @(-1);
    }else if (self.currentIndex == 3) {
        status = @(2);
    }
    
    NSString * pageIndexKey = [NSString stringWithFormat:@"%d",self.currentIndex];
    int pageIndexInt = [self.pageIndexDic[pageIndexKey] intValue];
    pageIndexInt = pageIndexInt == 0 ? 1 : pageIndexInt;
    NSDictionary *bodyDic = @{
                              @"storeId":storeId,
                              @"pageIndex":@(pageIndexInt),
                              @"pageSize":DRPageSize,
                              @"status":status,
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"B07",
                              };
    waitingView;
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        MJRefreshGifHeader *headerView = self.headerViews[self.currentIndex];
        MJRefreshBackGifFooter *footerView = self.footerViews[self.currentIndex];
        UITableView *tableView = self.views[self.currentIndex];
        if (SUCCESS) {
            NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
            NSArray * newDataArray_ = [DRGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (DRGoodModel * goodModel in newDataArray_) {
                NSInteger index = [newDataArray_ indexOfObject:goodModel];
                goodModel.specifications = [DRGoodSpecificationModel mj_objectArrayWithKeyValuesArray:json[@"list"][index][@"specifications"]];
            }
            [dataArray_ addObjectsFromArray:newDataArray_];
            [tableView reloadData];
            //结束刷新
            if ([headerView isRefreshing]) {
                [headerView endRefreshing];
            }
            if ([footerView isRefreshing]) {
                if (newDataArray_.count == 0) {
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
- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addGoodBarDidClick)];
    
    //添加3个btnTitle
    self.btnTitles = @[@"已上架",@"审核中",@"已驳回",@"已下架"];
    //添加3个tableview
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
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    if (DRArrayIsEmpty(dataArray_)) {
        [self getData];
    }
}
- (void)addGoodBarDidClick
{
    [self judgeMailWithGoodId:nil];
}
#pragma mark - 刷新
- (void)headerRefreshViewBeginRefreshing
{
    NSString * pageIndexKey = [NSString stringWithFormat:@"%d",self.currentIndex];
    [self.pageIndexDic setValue:[NSNumber numberWithInt:1] forKey:pageIndexKey];
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    [dataArray_ removeAllObjects];
    [self getData];
}
- (void)footerRefreshViewBeginRefreshing
{
    NSString * pageIndexKey = [NSString stringWithFormat:@"%d",self.currentIndex];
    NSNumber * pageIndex = self.pageIndexDic[pageIndexKey];
    int pageIndexInt = [pageIndex intValue];
    pageIndexInt = pageIndexInt == 0 ? 1 : pageIndexInt;
    pageIndexInt++;
    [self.pageIndexDic setValue:[NSNumber numberWithInt:pageIndexInt] forKey:pageIndexKey];
    [self getData];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    [tableView showNoDataWithTitle:@"" description:@"没有相关商品" rowCount:dataArray_.count];
    return dataArray_.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGoodShelfTableViewCell *cell = [DRGoodShelfTableViewCell cellWithTableView:tableView];
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    DRGoodModel * goodModel = dataArray_[indexPath.row];
    goodModel.type = self.currentIndex + 1;
    cell.model = goodModel;
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentIndex == 1) {
        return 145;
    }else if (self.currentIndex == 2)
    {
        NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
        DRGoodModel * goodModel = dataArray_[indexPath.row];
        CGSize rejectLabelSize = [goodModel.remark sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(22)]];
        CGFloat rejectLabelH = (rejectLabelSize.height + 15) < 35 ? 35 : (rejectLabelSize.height + 15);
        return 145 + rejectLabelH;
    }
    return 145 + 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    DRGoodModel * goodModel = dataArray_[indexPath.row];
    if (self.currentIndex == 2) {
        [self judgeMailWithGoodId:goodModel.id];
    }else if (self.currentIndex == 0)
    {
        DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
        goodVC.goodId = goodModel.id;
        [self.navigationController pushViewController:goodVC animated:YES];
    }
}
#pragma mark - 协议
- (void)goodShelfTableViewCell:(DRGoodShelfTableViewCell *)cell buttonDidClick:(UIButton *)button
{
    UITableView *tableView = self.views[self.currentIndex];
    NSIndexPath * indexPath = [tableView indexPathForCell:cell];
    NSMutableArray *dataArray_ = self.dataArray[self.currentIndex];
    DRGoodModel * goodModel = dataArray_[indexPath.row];

    if ([button.currentTitle isEqualToString:@"下架"] || [button.currentTitle isEqualToString:@"删除"]) {
        NSString * cmd;
        if ([button.currentTitle isEqualToString:@"下架"]) {
            cmd = @"B10";
        }else if ([button.currentTitle isEqualToString:@"删除"])
        {
            cmd = @"B09";
        }

        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"确认%@该商品?" ,button.currentTitle] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:button.currentTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            NSDictionary *bodyDic = @{
                                      @"id":goodModel.id,
                                      };

            NSDictionary *headDic = @{
                                      @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                      @"cmd":cmd,
                                      @"userId":UserId,
                                      };
            [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
                DRLog(@"%@",json);
                if (SUCCESS) {
                    [dataArray_ removeObjectAtIndex:indexPath.row];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    }else if ([button.currentTitle isEqualToString:@"编辑"])
    {
        [self judgeMailWithGoodId:goodModel.id];
    }
}

//判断是否设置邮费
- (void)judgeMailWithGoodId:(NSString *)goodId
{
    NSDictionary *bodyDic = @{
                              
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B15",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSString * conditionalMailId = json[@"conditionalMailId"];
            double ruleMoney = [json[@"ruleMoney"] doubleValue];
            double freight = [json[@"freight"] doubleValue];
            if (DRStringIsEmpty(conditionalMailId) || (ruleMoney > 0 && freight == 0)) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的运费信息不完善，请完善。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"去完善" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    DRMailSettingViewController * mailSettingVC = [[DRMailSettingViewController alloc] init];
                    [self.navigationController pushViewController:mailSettingVC animated:YES];
                }];
                [alertController addAction:alertAction1];
                [alertController addAction:alertAction2];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                DRPublishGoodViewController * addGoodVC = [[DRPublishGoodViewController alloc] init];
                addGoodVC.goodId = goodId;
                [self.navigationController pushViewController:addGoodVC animated:YES];
            }
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
        for (int i = 0; i < 4; i++) {
            NSMutableArray * dataArray_ = [NSMutableArray array];
            [_dataArray addObject:dataArray_];
        }
    }
    return _dataArray;
}
- (NSMutableDictionary *)pageIndexDic
{
    if (!_pageIndexDic) {
        _pageIndexDic = [NSMutableDictionary dictionary];
    }
    return _pageIndexDic;
}

@end
