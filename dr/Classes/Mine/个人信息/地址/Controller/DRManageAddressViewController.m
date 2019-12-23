//
//  DRManageAddressViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRManageAddressViewController.h"
#import "DRAddAddressViewController.h"
#import "DRAddressTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRManageAddressViewController ()<UITableViewDelegate,UITableViewDataSource, AddressTableViewCellDelegate ,AddAddressDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, weak) MJRefreshGifHeader *header;

@end

@implementation DRManageAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"收货地址";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    if (!Token || !UserId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U08",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            NSArray * addresss = [DRAddressModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            self.dataArray = [NSMutableArray arrayWithArray:addresss];
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
        if ([self.header isRefreshing]) {
            [self.header endRefreshing];
        }
        DRLog(@"error:%@",error);
    }];
}
//AddressTableViewCellDelegate
- (void)AddressTableViewCellDefaultButtonDidClick:(UIButton *)buton withCell:(DRAddressTableViewCell *)cell
{
    if (!Token || !UserId) {
        return;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DRAddressModel * addressModel = self.dataArray[indexPath.row];
    NSDictionary *bodyDic = @{
                              @"province":addressModel.province,
                              @"city":addressModel.city,
                              @"address":addressModel.address,
                              @"defaultv":[NSNumber numberWithInt:!buton.selected],
                              @"phone":addressModel.phone,
                              @"name":addressModel.name,
                              @"id":addressModel.id,
                              };
    
    NSDictionary *headDic = @{
                              @"province":addressModel.province,
                              @"city":addressModel.city,
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U07",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self getData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)AddressTableViewCellDeleteButtonDidClickWithCell:(DRAddressTableViewCell *)cell
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否确定删除该地址？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //删除地址
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        DRAddressModel * addressModel = self.dataArray[indexPath.row];
        if (!Token || !UserId) {
            return;
        }
        NSDictionary *bodyDic = @{
                                  @"id":addressModel.id,
                                  };
        
        NSDictionary *headDic = @{
                                  @"digest":[DRTool getDigestByBodyDic:bodyDic],
                                  @"cmd":@"U09",
                                  @"userId":UserId,
                                  };
        [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
            DRLog(@"%@",json);
            if (SUCCESS) {
                [self getData];
            }else
            {
                ShowErrorView
            }
        } failure:^(NSError *error) {
            DRLog(@"error:%@",error);
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAddressButtonDidClick)];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
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
- (void)addAddressButtonDidClick
{
    DRAddAddressViewController * addAddressVC = [[DRAddAddressViewController alloc] init];
    addAddressVC.delegate = self;
    [self.navigationController pushViewController:addAddressVC animated:YES];
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView showNoDataWithTitle:@"" description:@"您还没有地址" rowCount:self.dataArray.count];
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRAddressTableViewCell * cell = [DRAddressTableViewCell cellWithTableView:tableView];
    cell.addressModel = self.dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRAddressModel * addressModel = self.dataArray[indexPath.row];
    return addressModel.addressCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRAddressModel * addressModel = self.dataArray[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(manageAddressViewControllerSelectedAddressModel:)]) {
        [_delegate manageAddressViewControllerSelectedAddressModel:addressModel];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)AddressTableViewCellEditButtonDidClickWithCell:(DRAddressTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    DRAddAddressViewController * addAddressVC = [[DRAddAddressViewController alloc] init];
    addAddressVC.addressModel = self.dataArray[indexPath.row];
    addAddressVC.delegate = self;
    [self.navigationController pushViewController:addAddressVC animated:YES];
}
- (void)addAddressSuccess
{
    [self getData];
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
