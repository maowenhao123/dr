//
//  DRSetFunPasswordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/23.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSetFunPasswordViewController.h"
#import "DRValidateTool.h"

@interface DRSetFunPasswordViewController ()

@property (nonatomic, weak) UITextField * pswTF;
@property (nonatomic, weak) UITextField * confirmPswTF;

@end

@implementation DRSetFunPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置提款密码";
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
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    if (![DRValidateTool validateFunPassword:self.pswTF.text])
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
                              @"fundPassword":self.pswTF.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"%@",json);
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
