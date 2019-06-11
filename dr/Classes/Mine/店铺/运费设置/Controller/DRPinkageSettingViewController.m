//
//  DRPinkageSettingViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/16.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRPinkageSettingViewController.h"
#import "DRMailSettingModel.h"

@interface DRPinkageSettingViewController ()<UITextFieldDelegate>

@property (nonatomic,weak) UITextField *moneyTF;
@property (nonatomic,strong) NSMutableArray *buttons;
@property (nonatomic,strong) NSMutableArray *mailSettingArray;

@end

@implementation DRPinkageSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"包邮设置";
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B11",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.mailSettingArray = [DRMailSettingModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            [self setupChilds];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, 0)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    //包邮价格
    CGFloat buttonY = 20;
    CGFloat padding = 15;//按钮与边距间的距离
    CGFloat buttonPadding = 20;//按钮间的距离
    CGFloat buttonW = (screenWidth - 2 * padding - 2 * buttonPadding) / 3;
    CGFloat buttonH = 38;
    UIButton * lastButton;
    for (int i = 0; i < self.mailSettingArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(padding + (i % 3) * (buttonW + buttonPadding), buttonY + (i / 3) * (buttonH + buttonPadding), buttonW, buttonH);
        button.backgroundColor = [UIColor whiteColor];
        DRMailSettingModel * mailSettingModel = self.mailSettingArray[i];
        double ruleMoney = [mailSettingModel.ruleMoney doubleValue] / 100;
        NSString *buttonTitle = [NSString stringWithFormat:@"满%@包邮", [DRTool formatFloat:ruleMoney]];
        if (ruleMoney == 0) {
            buttonTitle = @"包邮";
        }
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:button.bounds] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage ImageFromColor:DRDefaultColor WithRect:button.bounds] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage ImageFromColor:DRDefaultColor WithRect:button.bounds] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.ruleMoney != nil && [self.ruleMoney doubleValue] == [mailSettingModel.ruleMoney doubleValue]) {
            button.selected = YES;
            button.layer.borderWidth = 0;
        } else {
            button.selected = NO;
            button.layer.borderWidth = 1;
        }
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3;
        button.layer.borderColor = DRWhiteLineColor.CGColor;
        [contentView addSubview:button];
        [self.buttons addObject:button];
        lastButton = button;
    }
    
    //金额输入框
    UITextField *moneyTF = [[UITextField alloc]initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lastButton.frame) + 30, screenWidth -  2 * DRMargin, 40)];
    self.moneyTF = moneyTF;
    moneyTF.textAlignment = NSTextAlignmentCenter;
    moneyTF.borderStyle = UITextBorderStyleNone;
    moneyTF.keyboardType = UIKeyboardTypeNumberPad;
    moneyTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    moneyTF.textColor = DRBlackTextColor;
    moneyTF.tintColor = DRDefaultColor;
    moneyTF.placeholder = @"自定义订单包邮金额";
    moneyTF.delegate = self;
    moneyTF.layer.borderColor = DRWhiteLineColor.CGColor;
    moneyTF.layer.borderWidth = 1;
    moneyTF.layer.cornerRadius = moneyTF.height / 2;
    if ([self.ruleMoney doubleValue] > 0) {
        self.moneyTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.ruleMoney doubleValue] / 100]];
    }
    [contentView addSubview:moneyTF];
    
    contentView.height = CGRectGetMaxY(moneyTF.frame) + 30;
    
    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(15, CGRectGetMaxY(contentView.frame) + 29, screenWidth - 30, 40);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = confirmButton.height / 2;
    [self.view addSubview:confirmButton];
}

- (void)buttonDidClick:(UIButton *)button
{
    [self.view endEditing:YES];
    
    if (button.isSelected) return;
    for (UIButton * button in self.buttons) {
        if (button.selected) {
            button.selected = NO;
            button.layer.borderWidth = 1;
        }
    }
    self.moneyTF.text = nil;
    button.selected = YES;
    button.layer.borderWidth = 0;
}

- (void)confirmButtonDidClick
{
    [self.view endEditing:YES];
    
    if (!DRStringIsEmpty(self.moneyTF.text)) {
        int money = [self.moneyTF.text intValue];
        [self addMailSettingMoney:@(money * 100)];
    }else
    {
        DRMailSettingModel * mailSettingModel;
        for (UIButton * button in self.buttons) {
            if (button.selected) {
                NSInteger index = [self.buttons indexOfObject:button];
                mailSettingModel = self.mailSettingArray[index];
            }
        }
        if (!mailSettingModel) {
            [MBProgressHUD showError:@"请输入包邮金额"];
            return;
        }
        self.ruleMoney = mailSettingModel.ruleMoney;
        [self confirmMailSettingWithId:mailSettingModel.id];
    }
}

- (void)addMailSettingMoney:(NSNumber *)money
{
    self.ruleMoney = money;
    
    NSDictionary *bodyDic = @{
                              @"ruleMoney":money
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B12",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [self confirmMailSettingWithId:json[@"id"]];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

- (void)confirmMailSettingWithId:(NSString *)mailSettingId
{
    NSDictionary *bodyDic = @{
                              @"id":mailSettingId
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B13",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            if (_delegate && [_delegate respondsToSelector:@selector(pinkageSettingSuccessWithMoney:)]) {
                [_delegate pinkageSettingSuccessWithMoney:self.ruleMoney];
            }
            [MBProgressHUD showSuccess:@"设置成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    for (UIButton * button in self.buttons) {
        if (button.selected) {
            button.selected = NO;
            button.layer.borderWidth = 1;
        }
    }
}

#pragma mark - 初始化
- (NSMutableArray *)buttons
{
    if(_buttons == nil)
    {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
