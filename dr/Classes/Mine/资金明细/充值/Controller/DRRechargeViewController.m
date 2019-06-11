//
//  DRRechargeViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRRechargeViewController.h"
#import "DRRechargeListViewController.h"

@interface DRRechargeViewController ()<UITextFieldDelegate>

@property (nonatomic,weak) UITextField *moneyTF;
@property (nonatomic,strong) NSMutableArray *buttons;

@end

@implementation DRRechargeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"充值";
    [self setupChilds];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //金额输入框
    UIView * moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    moneyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:moneyView];
    
    UITextField *moneyTF = [[UITextField alloc]initWithFrame:CGRectMake(DRMargin, 0, screenWidth -  2 * DRMargin, DRCellH)];
    self.moneyTF = moneyTF;
    moneyTF.textAlignment = NSTextAlignmentCenter;
    moneyTF.borderStyle = UITextBorderStyleNone;
    moneyTF.keyboardType = UIKeyboardTypeDecimalPad;
    moneyTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    moneyTF.textColor = DRBlackTextColor;
    moneyTF.tintColor = DRDefaultColor;
    moneyTF.placeholder = @"请输入充值金额";
    moneyTF.delegate = self;
    [moneyView addSubview:moneyTF];
    
    //4个金额按钮
    CGFloat buttonY = CGRectGetMaxY(moneyView.frame) + 30;
    CGFloat padding = 15;//按钮与边距间的距离
    CGFloat buttonPadding = 20;//按钮间的距离
    CGFloat buttonW = (screenWidth - 2 * padding - 3 * buttonPadding) / 4;
    CGFloat buttonH = 32;
    NSArray * buttonTitles = @[@"20", @"50", @"100", @"200"];
    UIButton * lastButton;
    for (int i = 0; i < buttonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(padding + i * (buttonW + buttonPadding), buttonY, buttonW, buttonH);
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        [button setTitleColor:DRDefaultColor forState:UIControlStateSelected];
        [button setTitleColor:DRDefaultColor forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.height / 2;
        button.layer.borderWidth = 1;
        button.layer.borderColor = DRGrayTextColor.CGColor;
        [self.view addSubview:button];
        [self.buttons addObject:button];
        lastButton = button;
    }
    
    //充值按钮
    UIButton * rechargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat rechargeBtnX = 15;
    CGFloat rechargeBtnY = CGRectGetMaxY(lastButton.frame) + 50;
    CGFloat rechargeW = screenWidth - 2 * rechargeBtnX;
    CGFloat rechargeBtnH = 40;
    rechargeBtn.frame = CGRectMake(rechargeBtnX, rechargeBtnY, rechargeW, rechargeBtnH);
    rechargeBtn.backgroundColor = DRDefaultColor;
    [rechargeBtn setTitle:@"充值" forState:UIControlStateNormal];
    [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rechargeBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    rechargeBtn.layer.masksToBounds = YES;
    rechargeBtn.layer.cornerRadius = rechargeBtnH / 2;
    [rechargeBtn addTarget:self action:@selector(rechargeBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rechargeBtn];
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"1、限整数，最小充值1元，1肉币=1元\n2、肉币可用于购买商品和抵扣运费，不可提现";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [promptAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(15, CGRectGetMaxY(rechargeBtn.frame) + 10, screenWidth - 15 * 2, promptSize.height);
    [self.view addSubview:promptLabel];
}
- (void)buttonDidClick:(UIButton *)button
{
    if (button.isSelected) return;
    for (UIButton * button in self.buttons) {
        if (button.selected) {
            button.selected = NO;
            button.layer.borderColor = DRGrayTextColor.CGColor;
        }
    }
    self.moneyTF.text = button.currentTitle;
    button.selected = YES;
    button.layer.borderColor = DRDefaultColor.CGColor;
}
#pragma mark- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    for (UIButton * button in self.buttons) {
        if (button.selected) {
            button.selected = NO;
            button.layer.borderColor = DRGrayTextColor.CGColor;
        }
    }
}
//限制金额输入框只能输入整数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isHaveDian = YES;
    if (textField.keyboardType == UIKeyboardTypeDecimalPad) {
        if ([textField.text rangeOfString:@"."].location==NSNotFound) {
            isHaveDian=NO;
        }
        if ([string length]>0)
        {
            unichar single=[string characterAtIndex:0];//当前输入的字符
            if ((single >='0' && single<='9') || single=='.')//数据格式正确
            {
                //首字母不能为0和小数点
                if([textField.text length]==0){
                    if(single == '.'){
                        //  [self alertView:@"亲，第一个数字不能为小数点"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                        
                    }
                }else if (textField.text.length == 1 && [textField.text isEqualToString:@"0"]){
                    if (single != '.') {
                        //     [self alertView:@"亲，第一个数字不能为0"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                        
                    }
                }
                if (single=='.')
                {
                    if(!isHaveDian)//text中还没有小数点
                    {
                        isHaveDian=YES;
                        return YES;
                    }else
                    {
                        //   [self alertView:@"亲，您已经输入过小数点了"];
                        [textField.text stringByReplacingCharactersInRange:range withString:@""];
                        return NO;
                    }
                }
                else
                {
                    if (isHaveDian)//存在小数点
                    {
                        //判断小数点的位数
                        NSRange ran=[textField.text rangeOfString:@"."];
                        NSInteger tt=range.location-ran.location;
                        if (tt <= 2){
                            return YES;
                        }else{
                            // [self alertView:@"亲，您最多输入两位小数"];
                            return NO;
                        }
                    }
                    else
                    {
                        return YES;
                    }
                }
            }else{//输入的数据格式不正确
                // [self alertView:@"亲，您输入的格式不正确"];
                [textField.text stringByReplacingCharactersInRange:range withString:@""];
                return NO;
            }
        }
        else
        {
            return YES;
        }
    }
    return YES;
}
- (void)rechargeBtnDidClick
{
    [self.view endEditing:YES];
    
    double money = 0;
    if (self.moneyTF.text.length > 0) {
        money = [self.moneyTF.text doubleValue];
    }
    for (UIButton * button in self.buttons) {
        if (button.selected) {
            money = [button.currentTitle doubleValue];
        }
    }
    if (money == 0) {
        [MBProgressHUD showError:@"请输入充值金额"];
        return;
    }
    
    DRRechargeListViewController * rechargeListVC = [[DRRechargeListViewController alloc] init];
    rechargeListVC.money = money;
    rechargeListVC.submitOrder = self.submitOrder;
    [self.navigationController pushViewController:rechargeListVC animated:YES];
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
