//
//  DRPraiseAwardAddressViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/25.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseAwardAddressViewController.h"
#import "DRPraiseListViewController.h"
#import "DRValidateTool.h"

@interface DRPraiseAwardAddressViewController ()

@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) UITextField * phoneTF;
@property (nonatomic, weak) UITextField * addressTF;

@end

@implementation DRPraiseAwardAddressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"填写地址";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 3 * DRCellH);
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    for (int i = 0; i < 3; i++) {
        UITextField * textField = [[UITextField alloc] init];
        textField.frame = CGRectMake(DRMargin, i * DRCellH, screenWidth - 2 * DRMargin, DRCellH);
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        [self.view addSubview:textField];
        if (i == 0) {
            textField.placeholder = @"收货人";
            self.nameTF = textField;
        }else if (i == 1)
        {
            textField.placeholder = @"手机电话";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.phoneTF = textField;
        }else if (i == 2)
        {
            textField.placeholder = @"收货地址";
            self.addressTF = textField;
        }
        [contentView addSubview:textField];
        //分割线
        if (i != 0) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH * i, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [contentView addSubview:line];
        }
    }
    
    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame) + 20, screenWidth - 2 * DRMargin, 45);
    UIImage * buttonBackImage = [UIImage resizedImageWithName:@"button_back_yellow" left:0.5 top:0.5];
    [confirmButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:DRColor(122, 22, 36, 1) forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
}

- (void)confirmButtonDidClick
{
    [self.view endEditing:YES];

    if (DRStringIsEmpty(self.nameTF.text))
    {
        [MBProgressHUD showError:@"您还未输入收货人"];
        return;
    }
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])
    {
        [MBProgressHUD showError:@"您输入的联系电话格式不对"];
        return;
    }
    
    if (DRStringIsEmpty(self.addressTF.text))
    {
        [MBProgressHUD showError:@"您还未输入收货地址"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"activityId": self.activityId,
                              @"receiveType": @(1),
                              @"type": self.type,
                              @"goodsId": self.goodsId,
                              @"recipients":self.nameTF.text,
                              @"phone":self.phoneTF.text,
                              @"shippingAddress":self.addressTF.text,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G05",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"领取中..." toView:self.view];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"领取成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PraiseAwardGoodSuccess" object:nil];
            
            UIViewController * praiseListVC = nil;
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[DRPraiseListViewController class]]) {
                    praiseListVC = viewController;
                    break;
                }
            }
            if (praiseListVC == nil) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else
            {
                [self.navigationController popToViewController:praiseListVC animated:YES];
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

@end
