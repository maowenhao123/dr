
//
//  DRChangeFunPassWordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/22.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeFunPassWordViewController.h"
#import "DRForgetFunPassWordViewController.h"
#import "DRValidateTool.h"

@interface DRChangeFunPassWordViewController ()

@property (nonatomic, weak) UITextField * oldPswTF;
@property (nonatomic, weak) UITextField * pswTF;

@end

@implementation DRChangeFunPassWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改提款密码";
    [self setupChilds];
}
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 2 * DRCellH);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    for (int i = 0; i < 2; i++) {
        UITextField * textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(DRMargin, i * DRCellH, screenWidth - 2 * DRMargin, DRCellH);
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        textField.secureTextEntry = YES;
        [self.view addSubview:textField];
        if (i == 0) {
            textField.placeholder = @"请输入原密码";
            self.oldPswTF = textField;
        }else if (i == 1)
        {
            textField.placeholder = @"请输入新密码";
            self.pswTF = textField;
        }
        [contentView addSubview:textField];
        //分割线
        if (i != 1) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH - 1, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [contentView addSubview:line];
        }
    }
    
    //忘记密码
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    CGSize buttonSize = [button.currentTitle sizeWithLabelFont:button.titleLabel.font];
    CGFloat buttonW = buttonSize.width;
    CGFloat buttonH = buttonSize.height;
    CGFloat buttonX = screenWidth - DRMargin - buttonW;
    CGFloat buttonY = CGRectGetMaxY(contentView.frame) + DRMargin;
    button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    [button addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonDidClick
{
    DRForgetFunPassWordViewController * forgetFunPassWordVC = [[DRForgetFunPassWordViewController alloc] init];
    [self.navigationController pushViewController:forgetFunPassWordVC animated:YES];
}

- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    if (![DRValidateTool validateFunPassword:self.oldPswTF.text])
    {
        [MBProgressHUD showError:@"您输入的原密码格式不对"];
        return;
    }
    if (![DRValidateTool validateFunPassword:self.pswTF.text])
    {
        [MBProgressHUD showError:@"您输入的新密码格式不对"];
        return;
    }
    if ([self.pswTF.text isEqualToString:self.oldPswTF.text])
    {
        [MBProgressHUD showError:@"您两次输入的密码一样"];
        return;
    }
    NSDictionary *bodyDic = @{
                              @"fundPassword":self.pswTF.text,
                              @"oldFundPassword":self.oldPswTF.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"设置成功"];
            DRUser *user = [DRUserDefaultTool user];
            user.hasFundPassword = YES;
            [DRUserDefaultTool saveUser:user];
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


@end
