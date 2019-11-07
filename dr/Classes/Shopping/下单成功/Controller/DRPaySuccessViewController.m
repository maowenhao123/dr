//
//  DRPaySuccessViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/3/30.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRPaySuccessViewController.h"
#import "DRTabBarViewController.h"
#import "DRShareTool.h"
#import "DRActivityView.h"

@interface DRPaySuccessViewController ()

@property (nonatomic,weak) UIScrollView * scrollView;
@property (nonatomic,weak) UIView * lastView;

@end

@implementation DRPaySuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"订单结果";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
    [self upDataUser];
    [self getActivityData];
}

#pragma mark - 请求数据
- (void)upDataUser
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U10",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
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

- (void)getActivityData
{
    if (!Token || !UserId || !self.orderId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"orderId":self.orderId
                              };

    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"L25",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            NSArray *activityList = [DRActivityModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self setupActivityViewWithActivityList:activityList];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)setupActivityViewWithActivityList:(NSArray *)activityList
{
    CGFloat activityViewPadding = 15;
    CGFloat activityViewW = (screenWidth - activityViewPadding * 3) / 2;
    CGFloat activityViewH = activityViewW / 2;
    for (int i = 0; i < activityList.count; i++) {
        DRActivityView * activityView = [[DRActivityView alloc] initWithFrame: CGRectMake(activityViewPadding + (activityViewPadding + activityViewW) * (i % 2), CGRectGetMaxY(self.lastView.frame) + 30 + (activityViewPadding + activityViewH) * (i / 2), activityViewW, activityViewH)];
        activityView.activityModel = activityList[i];
        if ((i % 2 == 0 && i == activityList.count - 1) || activityList.count == 1) {//最后一个居中
            activityView.centerX = screenWidth / 2;
        }
        [self.scrollView addSubview:activityView];
        
        self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(activityView.frame) + 10);
    }
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    //对号
    CGFloat paySuccessImageViewWH = 43;
    UIImageView * paySuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - paySuccessImageViewWH) / 2, 44, paySuccessImageViewWH, paySuccessImageViewWH)];
    paySuccessImageView.image = [UIImage imageNamed:@"pay_success_icon"];
    [scrollView addSubview:paySuccessImageView];
    
    //金额
    UILabel * moneyLabel = [[UILabel alloc] init];
    moneyLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:self.price]];
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(50)];
    moneyLabel.textColor = DRDefaultColor;
    CGSize moneyLabelSize = [moneyLabel.text sizeWithLabelFont:moneyLabel.font];
    moneyLabel.frame = CGRectMake((screenWidth - moneyLabelSize.width) / 2, CGRectGetMaxY(paySuccessImageView.frame) + 29, moneyLabelSize.width, moneyLabelSize.height);
    [scrollView addSubview:moneyLabel];
    
    //提示
    UILabel * hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"订单支付成功，等待卖家发货";
    hintLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    hintLabel.textColor = DRBlackTextColor;
    CGSize hintLabelSize = [hintLabel.text sizeWithLabelFont:hintLabel.font];
    hintLabel.frame = CGRectMake((screenWidth - hintLabelSize.width) / 2, CGRectGetMaxY(moneyLabel.frame) + 17, hintLabelSize.width, hintLabelSize.height);
    [scrollView addSubview:hintLabel];
    
    //按钮
    CGFloat buttonW = 118;
    CGFloat buttonH = 39;
    CGFloat buttonY = CGRectGetMaxY(moneyLabel.frame) + 73;
    CGFloat paddingButton = 60;
    CGFloat padding = (screenWidth - 2 * buttonW - paddingButton) / 2;
    if (self.grouponType != 0) {//团购
        UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake((screenWidth - (buttonW * 2 + paddingButton)) / 2, CGRectGetMaxY(moneyLabel.frame) + 73, (buttonW * 2 + paddingButton), 40);
        shareButton.backgroundColor = DRDefaultColor;
        [shareButton setTitle:@"邀请好友来拼团" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        shareButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.cornerRadius = shareButton.height / 2;
        [shareButton addTarget:self action:@selector(shareButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:shareButton];
        buttonY = CGRectGetMaxY(shareButton.frame) + 20;
    }

    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(padding + (buttonW + paddingButton) * i, buttonY, buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"查看订单" forState:UIControlStateNormal];
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
        [scrollView addSubview:button];
        
        self.lastView = button;
    }
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.lastView.frame) + 10);
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
            NSDictionary *objectDic = @{
                                        @"grouponType":@(self.grouponType),
                                        @"grouponFull":@(self.grouponFull)
                                        };
            if (button.tag == 0) {//查看订单
                [[NSNotificationCenter defaultCenter] postNotificationName:@"checkoutSuccess" object:objectDic];
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

- (void)shareButtonDidClick
{
    [DRShareTool shareGrouponByGrouponId:self.grouponId];
}

@end
