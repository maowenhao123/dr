//
//  DRBankCardViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBankCardViewController.h"
#import "DRAddBankCardViewController.h"
#import "DRBankCardTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRBankCardViewController ()<UITableViewDelegate, UITableViewDataSource, AddBankCardDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *header;

@end

@implementation DRBankCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的银行卡";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U12",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * bankCards = [DRBankCardModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            self.dataArray = [NSMutableArray arrayWithArray:bankCards];
            [self.tableView reloadData];
        }else
        {
            ShowErrorView
        }
        //结束刷新
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
    }];
}

- (void)deleteDataWithBankCardId:(NSString *)cardId indexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *bodyDic = @{
                              @"id":cardId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U13",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"银行卡删除成功"];
            [self.dataArray removeObjectAtIndex:indexPath.section];
            [self.tableView reloadData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //添加银行卡
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addBankCardBtnClick)];
    
    //tableview
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    self.header = header;
    [DRTool setRefreshHeaderData:header];
    tableView.mj_header = header;
}

- (void)addBankCardBtnClick
{
    DRAddBankCardViewController * addBankCardVC = [[DRAddBankCardViewController alloc] init];
    addBankCardVC.delegate = self;
    [self.navigationController pushViewController:addBankCardVC animated:YES];
}

//添加银行卡成功后刷新
- (void)addBankSuccess
{
    [self getData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView showNoDataWithTitle:@"" description:@"暂无数据" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRBankCardTableViewCell * cell = [DRBankCardTableViewCell cellWithTableView:tableView];
    DRBankCardModel * bankCardModel = self.dataArray[indexPath.section];
    cell.model = bankCardModel;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.dataArray.count - 1 == section) {
        return 10;
    }
    return 0.01;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//自定义删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count == 0) {//没有数据时
        return;
    }
    //删除银行卡
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确认删除银行卡?删除后不可复原。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        DRBankCardModel * bankCardModel = self.dataArray[indexPath.section];
        [self deleteDataWithBankCardId:bankCardModel.id indexPath:indexPath];
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
