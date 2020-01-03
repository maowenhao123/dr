//
//  DRMyFansViewController.m
//  dr
//
//  Created by dahe on 2019/12/16.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRMyFansViewController.h"
#import "DRShowViewController.h"
#import "DRMailSettingViewController.h"
#import "DRPublishGoodViewController.h"
#import "DRIconTextTableViewCell.h"
#import "DRMyFansModel.h"

@interface DRMyFansViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, weak) UILabel * noDataLabel;
@property (nonatomic, weak) UIButton * addBtn;
@property (nonatomic, weak) UIView * noDataView;
@property (nonatomic, weak) MJRefreshGifHeader *headerView;
@property (nonatomic, weak) MJRefreshBackGifFooter *footerView;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRMyFansViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isShop) {
        self.title = @"店铺粉丝";
    }else
    {
        self.title = @"我的粉丝";
    }
    [self setupChilds];
    self.pageIndex = 1;
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    if (!Token || !UserId) {
        return;
    }
    NSDictionary *bodyDic = @{
        @"pageIndex":@(self.pageIndex),
        @"pageSize":DRPageSize,
    };
    
    NSString * cmd = @"B24";
    if (self.isShop) {
        cmd = @"B23";
    }
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":cmd,
        @"userId":UserId,
    };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (self.pageIndex == 1) {
                [self.dataArray removeAllObjects];
            }
            NSArray * fanList = [DRMyFansModel mj_objectArrayWithKeyValuesArray:json[@"fanList"]];
            [self.dataArray addObjectsFromArray:fanList];
            if (self.dataArray.count == 0) {
                self.noDataView.hidden = NO;
                self.tableView.hidden = YES;
                if (self.isShop) {
                    self.noDataLabel.text = @"抱歉，店铺还没有粉丝，快去上新品吧！";
                    [self.addBtn setTitle:@"去发布商品" forState:UIControlStateNormal];
                }else
                {
                    self.noDataLabel.text = @"抱歉，您还没有粉丝，快去玩家秀场发帖集人气吧！";
                    [self.addBtn setTitle:@"前往玩家秀场" forState:UIControlStateNormal];
                }
            }else
            {
                self.noDataView.hidden = YES;
                self.tableView.hidden = NO;
            }
            [self.tableView reloadData];
            if (fanList.count == 0) {
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
    //noDataView
    UIView * noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.noDataView = noDataView;
    [self.view addSubview:noDataView];
    
    UILabel * noDataLabel = [[UILabel alloc] init];
    self.noDataLabel = noDataLabel;
    noDataLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    noDataLabel.textColor = DRGrayTextColor;
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.text = @"抱歉，您还没有粉丝，快去玩家秀场发帖集人气吧！";
    CGSize noDataLabelSize = [noDataLabel.text sizeWithFont:noDataLabel.font maxSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT)];
    noDataLabel.frame = CGRectMake(DRMargin, self.view.height * 0.3, screenWidth, noDataLabelSize.height);
    [noDataView addSubview:noDataLabel];
    
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addBtn = addBtn;
    addBtn.frame = CGRectMake(screenWidth * 0.2, CGRectGetMaxY(noDataLabel.frame) + DRMargin, screenWidth * 0.6, 40);
    addBtn.backgroundColor = DRDefaultColor;
    [addBtn setTitle:@"前往玩家秀场" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [addBtn addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = addBtn.height / 2;
    [noDataView addSubview:addBtn];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
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

- (void)headerRefreshViewBeginRefreshing
{
    self.pageIndex = 1;
    [self getData];
}

- (void)footerRefreshViewBeginRefreshing
{
    self.pageIndex++;
    [self getData];
}

- (void)addButtonDidClick
{
    if (self.isShop) {
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
    }else
    {
        DRShowViewController * showVC = [[DRShowViewController alloc] init];
        [self.navigationController pushViewController:showVC animated:YES];
    }
}

#pragma mark - cell delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRIconTextTableViewCell *cell = [DRIconTextTableViewCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DRMyFansModel * fansModel = self.dataArray[indexPath.row];
    cell.functionName = fansModel.nickName;
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, fansModel.headImg];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    cell.iconImageView.layer.masksToBounds = YES;
    cell.iconImageView.layer.cornerRadius = 60 * 0.6 / 2;
    cell.accessoryImageView.hidden = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
