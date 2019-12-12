//
//  DRPayViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/17.
//  Copyright © 2017年 JG. All rights reserved.
//
#import <AlipaySDK/AlipaySDK.h>
#import "DRPayViewController.h"
#import "DRPaySuccessViewController.h"
#import "DRIconTextTableViewCell.h"
#import "WXApi.h"
#import "NSString+SBJSON.h"
#import "JSON.h"

@interface DRPayViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *functionStatuss;

@end

@implementation DRPayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"收银台";
    [self setupChilds];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAliPayResultStatus:) name:@"aliPayResultStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiXinPaySuccess) name:@"WeiXinRechargeSuccessNote" object:nil];
}

#pragma mark - 支付充值结果回调
-(void)setAliPayResultStatus:(NSNotification *)result
{
    NSInteger resultStatus = [result.userInfo[@"resultStatus"] integerValue];
    
    if (resultStatus == 9000) {
        [self postPaySuccessNote];
        DRPaySuccessViewController * paySuccessGoodVC = [[DRPaySuccessViewController alloc] init];
        paySuccessGoodVC.grouponType = self.grouponType;
        paySuccessGoodVC.price = self.price;
        if (self.grouponType != 0) {
            paySuccessGoodVC.grouponId = self.grouponId;
        }
        paySuccessGoodVC.orderId = self.orderId;
        [self.navigationController pushViewController:paySuccessGoodVC animated:YES];
    }
}

- (void)weiXinPaySuccess
{
    [self postPaySuccessNote];
    DRPaySuccessViewController * paySuccessGoodVC = [[DRPaySuccessViewController alloc] init];
    paySuccessGoodVC.grouponType = self.grouponType;
    paySuccessGoodVC.price = self.price;
    if (self.grouponType != 0) {
        paySuccessGoodVC.grouponId = self.grouponId;
    }
    paySuccessGoodVC.orderId = self.orderId;
    [self.navigationController pushViewController:paySuccessGoodVC animated:YES];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 67 + 39)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //金额
    UIView * payMoneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 67)];
    payMoneyView.backgroundColor = DRDefaultColor;
    [headerView addSubview:payMoneyView];
    
    UILabel * payMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 67)];
    payMoneyLabel.text = [NSString stringWithFormat:@"订单金额：¥%@", [DRTool formatFloat:self.price]];
    payMoneyLabel.textColor = [UIColor whiteColor];
    payMoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [payMoneyView addSubview:payMoneyLabel];

    //支付方式
    UILabel * payTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 67, screenWidth - 2 * DRMargin, 39)];
    payTitleLabel.text = @"选择支付方式";
    payTitleLabel.textColor = DRGrayTextColor;
    payTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [headerView addSubview:payTitleLabel];
    tableView.tableHeaderView = headerView;
}

#pragma mark - cell delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.functionStatuss.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRIconTextTableViewCell *cell = [DRIconTextTableViewCell cellWithTableView:tableView];
    if (indexPath.row == 0) {
        DRUser *user = [DRUserDefaultTool user];
        cell.functionDetail = [NSString stringWithFormat:@"余%@元", [DRTool formatFloat:[user.balance doubleValue] / 100]];
    }
    DRFunctionStatus * status = self.functionStatuss[indexPath.row];
    cell.functionName = status.functionName;
    cell.icon = status.functionIconName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DRCellH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self accountPayWithRow:indexPath.row];
}

- (void)accountPayWithRow:(NSInteger)row
{
    NSDictionary *bodyDic = @{
                              @"orderId":self.orderId,
                              @"chargeType":@(row),
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S05",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (row == 0) {
                [self postPaySuccessNote];
                DRPaySuccessViewController * paySuccessGoodVC = [[DRPaySuccessViewController alloc] init];
                paySuccessGoodVC.grouponType = self.grouponType;
                paySuccessGoodVC.price = self.price;
                if (self.grouponType != 0) {
                    paySuccessGoodVC.grouponId = self.grouponId;
                }
                paySuccessGoodVC.orderId = self.orderId;
                paySuccessGoodVC.grouponFull = self.grouponFull;
                [self.navigationController pushViewController:paySuccessGoodVC animated:YES];
            }else if (row == 1)
            {
                NSString *orderString = json[@"data"];
                if (orderString != nil) {
                   NSString * appScheme = @"DRAlipay";
                    // NOTE: 调用支付结果开始支付
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"aliPayResultStatus" object:nil userInfo:resultDic];
                    }];
                }
            }else if (row == 2)
            {
                NSDictionary *dict = [json[@"data"] JSONValue];
                
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = dict[@"partnerid"];
                request.prepayId = dict[@"prepayid"];
                request.package = dict[@"package"];
                request.nonceStr = dict[@"noncestr"];
                request.timeStamp = [dict[@"timestamp"] unsignedIntValue];
                request.sign = dict[@"sign"];
                
                [WXApi sendReq:request];
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

- (void)postPaySuccessNote
{
    if (self.type == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"orderListRefresh" object:nil userInfo:nil];
    }else if (self.type == 2)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"orderDetailRefresh" object:nil userInfo:nil];
    }
}
#pragma mark - 初始化
- (NSMutableArray *)functionStatuss
{
    if (!_functionStatuss) {
        _functionStatuss = [NSMutableArray array];
        NSArray * functionNames = @[@"肉币支付", @"支付宝", @"微信"];
        NSArray * functionIconNames = @[@"pay_account_icon", @"pay_zhifubao_icon", @"pay_weixin_icon"];
        for (int i = 0; i < functionNames.count; i++) {
            DRFunctionStatus * status = [[DRFunctionStatus alloc]init];
            status.functionName = functionNames[i];
            status.functionIconName = functionIconNames[i];
            [_functionStatuss addObject:status];
        }
    }
    return _functionStatuss;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
