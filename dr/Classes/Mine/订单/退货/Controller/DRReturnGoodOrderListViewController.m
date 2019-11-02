//
//  DRReturnGoodOrderListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodOrderListViewController.h"
#import "DRReturnGoodViewController.h"
#import "DRReturnGoodDetailViewController.h"
#import "DRReturnGoodOrderTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRReturnGoodOrderListViewController ()<UITableViewDelegate,UITableViewDataSource, ReturnGoodOrderTableViewCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation DRReturnGoodOrderListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"待退款";
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"returnGoodSuccess" object:nil];
    [self getData];
    [self setupChilds];
}
- (void)getData
{
    NSDictionary *bodyDic_ = @{
                               };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.orderId)) {
        [bodyDic setObject:self.orderId forKey:@"orderId"];
    }
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S30",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray *dataArray = [DRCommentGoodModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            self.dataArray = dataArray;
            [self.tableView reloadData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
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
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    headerView.backgroundColor = DRBackgroundColor;
    tableView.tableHeaderView = headerView;
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
    DRReturnGoodOrderTableViewCell * cell = [DRReturnGoodOrderTableViewCell cellWithTableView:tableView];
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    cell.delegate = self;
    cell.commentGoodModel = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRCommentGoodModel * commentGoodModel = self.dataArray[indexPath.row];
    if ([commentGoodModel.refundStatus intValue] != 0) {
//        DRReturnGoodDetailViewController * returnGoodVC = [[DRReturnGoodDetailViewController alloc] init];
//        returnGoodVC.goodsId = commentGoodModel.goods.id;
//        returnGoodVC.orderId = commentGoodModel.orderId;
//        returnGoodVC.id = commentGoodModel.id;
//        if (!DRObjectIsEmpty(commentGoodModel.specification)) {
//            returnGoodVC.specificationId = commentGoodModel.specification.id;
//        }
//        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }else
    {
        DRReturnGoodViewController * returnGoodVC = [[DRReturnGoodViewController alloc] init];
        returnGoodVC.commentGoodModel = self.dataArray[indexPath.row];
        [self.navigationController pushViewController:returnGoodVC animated:YES];
    }
}

- (void)returnGoodOrderTableViewCell:(DRReturnGoodOrderTableViewCell *)cell returnGoodButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    DRReturnGoodViewController * returnGoodVC = [[DRReturnGoodViewController alloc] init];
    returnGoodVC.commentGoodModel = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:returnGoodVC animated:YES];
}

#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

@end
