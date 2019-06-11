//
//  DRSetupPasswordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/22.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSetupPasswordViewController.h"
#import "DRValidateTool.h"
#import "JSON.h"

@interface DRSetupPasswordViewController ()

@property (nonatomic, weak) UITextField * pswTF;
@property (nonatomic, weak) UITextField * confirmPswTF;

@end

@implementation DRSetupPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置密码";
    [self setupChilds];
}
- (void)setupChilds
{
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
        [self.view addSubview:textField];
        if (i == 0) {
            textField.placeholder = @"请输入密码，6-20位字母、数字组合";
            self.pswTF = textField;
        }else if (i == 1)
        {
            textField.placeholder = @"请再次输入密码";
            self.confirmPswTF = textField;
        }
        [contentView addSubview:textField];
        //分割线
        if (i != 1) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH - 1, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [contentView addSubview:line];
        }
    }
    
    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame) + 50, screenWidth - 2 * DRMargin, 40);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    confirmButton.layer.masksToBounds = YES;
    confirmButton.layer.cornerRadius = confirmButton.height / 2;
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
}
- (void)confirmButtonDidClick
{
    [self.view endEditing:YES];
    
    if (![DRValidateTool validatePassword :self.pswTF.text])
    {
        [MBProgressHUD showError:@"您输入的密码格式不对"];
        return;
    }
    if (![self.pswTF.text isEqualToString:self.confirmPswTF.text])
    {
        [MBProgressHUD showError:@"您两次输入的密码不一样"];
        return;
    }
    NSDictionary *bodyDic = @{
                              @"password":self.pswTF.text
                              };
    
    NSString * digest = [[NSString stringWithFormat:@"%@%@",[bodyDic JSONFragment], self.token] md5HexDigest];
    NSDictionary *headDic = @{
                              @"digest":digest,
                              @"userId":self.userId,
                              @"cmd":@"U06",
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"设置成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
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
