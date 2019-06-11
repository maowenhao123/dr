//
//  DRRechargeSuccessViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRRechargeSuccessViewController.h"
#import "DRSubmitOrderViewController.h"

@interface DRRechargeSuccessViewController ()

@end

@implementation DRRechargeSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"充值结果";
    self.view.backgroundColor = [UIColor whiteColor];
    [self getData];
    [self setupChilds];
}
- (void)getData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U10",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //储存
            DRUser *user = [DRUser mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveUser:user];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChilds
{
    //对号
    CGFloat paySuccessImageViewWH = 43;
    UIImageView * paySuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - paySuccessImageViewWH) / 2, 44, paySuccessImageViewWH, paySuccessImageViewWH)];
    paySuccessImageView.image = [UIImage imageNamed:@"pay_success_icon"];
    [self.view addSubview:paySuccessImageView];
    
    //金额
    UILabel * moneyLabel = [[UILabel alloc] init];
    moneyLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:self.money]];
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(50)];
    moneyLabel.textColor = DRDefaultColor;
    CGSize moneyLabelSize = [moneyLabel.text sizeWithLabelFont:moneyLabel.font];
    moneyLabel.frame = CGRectMake((screenWidth - moneyLabelSize.width) / 2, CGRectGetMaxY(paySuccessImageView.frame) + 29, moneyLabelSize.width, moneyLabelSize.height);
    [self.view addSubview:moneyLabel];
    
    //提示
    UILabel * hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"充值成功";
    hintLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    hintLabel.textColor = DRBlackTextColor;
    CGSize hintLabelSize = [hintLabel.text sizeWithLabelFont:hintLabel.font];
    hintLabel.frame = CGRectMake((screenWidth - hintLabelSize.width) / 2, CGRectGetMaxY(moneyLabel.frame) + 17, hintLabelSize.width, hintLabelSize.height);
    [self.view addSubview:hintLabel];
    
    //按钮
    CGFloat buttonW = 118;
    CGFloat buttonH = 39;
    CGFloat buttonY = CGRectGetMaxY(moneyLabel.frame) + 73;
    CGFloat paddingButton = 60;
    CGFloat padding = (screenWidth - 2 * buttonW - paddingButton) / 2;
    if (self.submitOrder) {//提交订单页面
        UIButton * backSubmitOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backSubmitOrderButton.frame = CGRectMake((screenWidth - (buttonW * 2 + paddingButton)) / 2, CGRectGetMaxY(moneyLabel.frame) + 73, (buttonW * 2 + paddingButton), 40);
        backSubmitOrderButton.backgroundColor = DRDefaultColor;
        [backSubmitOrderButton setTitle:@"返回订单" forState:UIControlStateNormal];
        [backSubmitOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backSubmitOrderButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        backSubmitOrderButton.layer.masksToBounds = YES;
        backSubmitOrderButton.layer.cornerRadius = backSubmitOrderButton.height / 2;
        [backSubmitOrderButton addTarget:self action:@selector(backSubmitOrderButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backSubmitOrderButton];
        buttonY = CGRectGetMaxY(backSubmitOrderButton.frame) + 20;
    }

    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(padding + (buttonW + paddingButton) * i, buttonY, buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"个人中心" forState:UIControlStateNormal];
        }else
        {
            [button setTitle:@"返回首页" forState:UIControlStateNormal];
        }
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonH / 2;
        button.layer.borderColor = DRWhiteLineColor.CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}
- (void)backSubmitOrderButtonDidClick
{
    UIViewController * submitOrderVC;
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DRSubmitOrderViewController class]]) {
            submitOrderVC = vc;
        }
    }
    if (!submitOrderVC) return;
    [self.navigationController popToViewController:submitOrderVC animated:YES];
}
- (void)buttonDidClick:(UIButton *)button
{
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (button.tag == 0) {//我的
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoMine" object:nil];
            }else//返回首页
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoHomePage" object:nil];
            }
            
        });
    }];
    [op2 addDependency:op1];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue waitUntilAllOperationsAreFinished];
    [queue addOperation:op1];
    [queue addOperation:op2];
}

@end
