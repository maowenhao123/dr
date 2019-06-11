//
//  DRRechargeListViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <AlipaySDK/AlipaySDK.h>
#import "DRRechargeListViewController.h"
#import "DRRechargeSuccessViewController.h"
#import "DRIconTextTableViewCell.h"
#import "WXApi.h"
#import "NSString+SBJSON.h"
#import "JSON.h"

@interface DRRechargeListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *functionStatuss;

@end

@implementation DRRechargeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"充值列表";
    [self setupChilds];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAliPayResultStatus:) name:@"aliPayResultStatus" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiXinPaySuccess) name:@"WeiXinRechargeSuccessNote" object:nil];
}

#pragma mark - 支付充值结果回调
-(void)setAliPayResultStatus:(NSNotification *)result{
    NSInteger resultStatus = [result.userInfo[@"resultStatus"] integerValue];
    
    if (resultStatus == 9000) {
        DRRechargeSuccessViewController * rechargeSuccessGoodVC = [[DRRechargeSuccessViewController alloc] init];
        rechargeSuccessGoodVC.money = self.money;
        rechargeSuccessGoodVC.submitOrder = self.submitOrder;
        [self.navigationController pushViewController:rechargeSuccessGoodVC animated:YES];
    }
}
- (void)weiXinPaySuccess
{
    DRRechargeSuccessViewController * rechargeSuccessGoodVC = [[DRRechargeSuccessViewController alloc] init];
    rechargeSuccessGoodVC.money = self.money;
    rechargeSuccessGoodVC.submitOrder = self.submitOrder;
    [self.navigationController pushViewController:rechargeSuccessGoodVC animated:YES];
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
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    headerView.backgroundColor = DRBackgroundColor;
    tableView.tableHeaderView = headerView;
}
#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.functionStatuss.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRIconTextTableViewCell *cell = [DRIconTextTableViewCell cellWithTableView:tableView];
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
    [self rechargeWithRow:indexPath.row];
}
- (void)rechargeWithRow:(NSInteger)row
{
    NSNumber * money = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:self.money]];
    NSDictionary *bodyDic = @{
                              @"money":money,
                              @"chargeType":@(row + 1),
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U30",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (row == 0)
            {
                NSString *orderString = json[@"data"];
                if (orderString != nil) {
                    NSString * appScheme = @"DRAlipay";
                    // NOTE: 调用支付结果开始支付
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"aliPayResultStatus" object:nil userInfo:resultDic];
                    }];
                }
            }else if (row == 1)
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
#pragma mark - 初始化
- (NSMutableArray *)functionStatuss
{
    if (!_functionStatuss) {
        _functionStatuss = [NSMutableArray array];
        NSArray * functionNames = @[@"支付宝", @"微信"];
        NSArray * functionIconNames = @[@"pay_zhifubao_icon", @"pay_weixin_icon"];
        for (int i = 0; i < functionNames.count; i++) {
            DRFunctionStatus * status = [[DRFunctionStatus alloc]init];
            status.functionName = functionNames[i];
            status.functionIconName = functionIconNames[i];
            [_functionStatuss addObject:status];
        }
    }
    return _functionStatuss;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
