//
//  DRLoginViewController.m
//  dr
//
//  Created by apple on 17/2/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UMSocialCore/UMSocialCore.h>
#import "DRLoginViewController.h"
#import "DRBaseNavigationController.h"
#import "DRRegisterViewController.h"
#import "DRThirdPartyBindingViewController.h"
#import "DRForgetPasswordViewController.h"
#import "JSON.h"
#import "WXApi.h"

@interface DRLoginViewController ()

@property (nonatomic, weak) UITextField * accountTF;
@property (nonatomic, weak) UITextField * passwordTF;
@property (nonatomic, weak) UIButton * showPasswordButton;
@property (nonatomic, weak) UIButton * loginBtn;

@end

@implementation DRLoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.accountTF];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.passwordTF];
}
#pragma mark - 布局子控件
- (void)setupChilds
{
    //close
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat closeButtonWH = 30;
    closeButton.frame = CGRectMake(screenWidth - closeButtonWH - 10, statusBarH + 10, closeButtonWH, closeButtonWH);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"login_close_icon"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //login
    UIImageView * logoImageView = [[UIImageView alloc] init];
    CGFloat logoImageViewWH = 80;
    logoImageView.frame = CGRectMake((screenWidth - logoImageViewWH) / 2, statusBarH + 44, logoImageViewWH, logoImageViewWH);
    logoImageView.image = [UIImage imageNamed:@"login_icon"];
    [self.view addSubview:logoImageView];
    
    UIView * lastView;
    //输入框
    NSArray * placeholders = @[@"吾花肉账号",@"请输入密码"];
    CGFloat textFieldH = 52;
    
    for (int i = 0; i < 2; i++) {
        UITextField * textField = [[UITextField alloc] init];
        textField.tintColor = DRDefaultColor;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        textField.textColor = DRBlackTextColor;
        textField.placeholder = placeholders[i];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.borderStyle = UITextBorderStyleNone;
        CGFloat textFieldX = DRMargin;
        CGFloat textFieldY = CGRectGetMaxY(logoImageView.frame) + 34;
        CGFloat textFieldW = screenWidth - 2 * textFieldX;
        if (i == 0) {//账号
            self.accountTF = textField;
        }else//密码
        {
            self.passwordTF = textField;
            textFieldX += 30;
            textFieldY = CGRectGetMaxY(lastView.frame);
            textFieldW -= 2 * 30;
            textField.secureTextEntry = YES;
        }
        textField.frame = CGRectMake(textFieldX, textFieldY, textFieldW, textFieldH);
        [self.view addSubview:textField];
        lastView = textField;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(textField.frame) - 1, screenWidth - 2 * DRMargin, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [self.view addSubview:line];
    }
    self.accountTF.text = [DRUserDefaultTool getObjectForKey:@"login_name"];
    
    UIButton * showPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.showPasswordButton = showPasswordButton;
    CGFloat showPasswordButtonWH = 20;
    showPasswordButton.frame = CGRectMake(screenWidth - showPasswordButtonWH - DRMargin, 0, showPasswordButtonWH, showPasswordButtonWH);
    showPasswordButton.centerY = self.passwordTF.centerY;
    [showPasswordButton setBackgroundImage:[UIImage imageNamed:@"login_password_invisible"] forState:UIControlStateNormal];
    [showPasswordButton setBackgroundImage:[UIImage imageNamed:@"login_password_visible"] forState:UIControlStateSelected];
    [showPasswordButton addTarget:self action:@selector(showPasswordButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showPasswordButton];
    
    //登录按钮
    UIButton * loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn = loginBtn;
    CGFloat buttonX = DRMargin;
    CGFloat buttonY = CGRectGetMaxY(lastView.frame) + 30;
    CGFloat buttonW = screenWidth - 2 * buttonX;
    CGFloat buttonH = 39;
    loginBtn.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    loginBtn.backgroundColor = DRColor(218, 218, 218, 1);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    loginBtn.enabled = NO;
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = buttonH / 2;
    [loginBtn addTarget:self action:@selector(loginBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    lastView = loginBtn;
    
    //忘记密码
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitle:@"忘记密码?" forState:UIControlStateNormal];
        if (i == 1) {
            [button setTitle:@"新用户注册" forState:UIControlStateNormal];
        }
        [button setTitleColor:DRColor(83, 83, 83, 1) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        CGSize buttonSize = [button.currentTitle sizeWithLabelFont:button.titleLabel.font];
        CGFloat buttonW = buttonSize.width;
        CGFloat buttonH = buttonSize.height;
        CGFloat buttonX = DRMargin;
        if (i == 1) {
            buttonX = screenWidth - DRMargin - buttonW;
        }
        CGFloat buttonY = CGRectGetMaxY(lastView.frame) + 30;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    //第三方登录
    UIView *thirdPartyView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - 83 - [DRTool getSafeAreaBottom], screenWidth, 83)];
    thirdPartyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:thirdPartyView];
    
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.text = @"or";
    promptLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    promptLabel.textColor = DRColor(148, 148, 148, 1);
    CGSize promptSize = [promptLabel.text sizeWithLabelFont:promptLabel.font];
    CGFloat promptLabelX = (screenWidth - promptSize.width) / 2;
    promptLabel.frame = CGRectMake(promptLabelX, 0, promptSize.width, promptSize.height);
    [thirdPartyView addSubview:promptLabel];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(10, 0, promptLabel.x - 10 - 10, 1)];
    line1.centerY = promptLabel.centerY;
    line1.backgroundColor = DRWhiteLineColor;
    [thirdPartyView addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(promptLabel.frame) + 10, 0, screenWidth - CGRectGetMaxX(promptLabel.frame) - 10 - 10, 1)];
    line2.centerY = promptLabel.centerY;
    line2.backgroundColor = DRWhiteLineColor;
    [thirdPartyView addSubview:line2];

    CGFloat thirdPartyBtnWH = 38;
    CGFloat thirdPartyBtnY = thirdPartyView.height - 17 - thirdPartyBtnWH;
    NSMutableArray *thirdPartyBtnImages = [NSMutableArray array];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {//如果安装微信
        [thirdPartyBtnImages addObject:@"login_weixin_icon"];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {//如果安装QQ
        [thirdPartyBtnImages addObject:@"login_qq_icon"];
    }
    CGFloat thirdPartyBtnPadding = (screenWidth - thirdPartyBtnWH * thirdPartyBtnImages.count) / (thirdPartyBtnImages.count + 1);
    if (thirdPartyBtnImages.count == 0) {
        thirdPartyView.hidden = YES;
    }
    for (int i = 0; i < thirdPartyBtnImages.count; i++) {
        UIButton * thirdPartyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdPartyBtn.frame = CGRectMake(thirdPartyBtnPadding + (thirdPartyBtnWH + thirdPartyBtnPadding) * i, thirdPartyBtnY, thirdPartyBtnWH, thirdPartyBtnWH);
        if ([thirdPartyBtnImages[i] isEqualToString:@"login_qq_icon"]) {
            thirdPartyBtn.tag = 101;
        }else if ([thirdPartyBtnImages[i] isEqualToString:@"login_weixin_icon"]) {
            thirdPartyBtn.tag = 102;
        }
        [thirdPartyBtn setBackgroundImage:[UIImage imageNamed:thirdPartyBtnImages[i]] forState:UIControlStateNormal];
        [thirdPartyBtn addTarget:self action:@selector(thirdPartyBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [thirdPartyView addSubview:thirdPartyBtn];
    }
}

#pragma mark - 按钮点击
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPasswordButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.passwordTF.secureTextEntry = NO;
    } else
    {
        self.passwordTF.secureTextEntry = YES;
    }
}

- (void)loginBtnDidClick:(UIButton *)button
{
    [self.view endEditing:YES];
    
    NSDictionary *headDic = @{
                              @"cmd":@"U02"
                              };
    NSDictionary *bodyDic = @{
                              @"password":self.passwordTF.text,
                              @"login_name":self.accountTF.text
                              };
    waitingView;
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            //存储login_name
            [DRUserDefaultTool saveObject:self.accountTF.text forKey:@"login_name"];
            
            //存储userId和digest
            [DRUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
            [DRUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
            //登录时间
            [DRUserDefaultTool saveObject:[DRTool getNowTimeTimestamp] forKey:@"lastLoginTime"];
            
            [self getShopData];
            
            [DRTool loginImAccount];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            //登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

//请求店铺数据
- (void)getShopData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B01",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRMyShopModel *shopModel = [DRMyShopModel mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveMyShopModel:shopModel];
        }else
        {
            [DRUserDefaultTool removeShop];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) {//忘记密码?
        DRForgetPasswordViewController *forgetPasswordVC = [[DRForgetPasswordViewController alloc] init];
        DRBaseNavigationController *nav = [[DRBaseNavigationController alloc]initWithRootViewController:forgetPasswordVC];
        [self presentViewController:nav animated:YES completion:nil];
    }else//新用户注册
    {
        DRRegisterViewController *registerVC = [[DRRegisterViewController alloc] init];
        DRBaseNavigationController *nav = [[DRBaseNavigationController alloc]initWithRootViewController:registerVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - 第三方登录
- (void)thirdPartyBtnDidClick:(UIButton *)button
{
    if (button.tag == 101) {//qq
        [self getUserInfoForPlatform:UMSocialPlatformType_QQ];
    }else if (button.tag == 102)//微信
    {
        [self getUserInfoForPlatform:UMSocialPlatformType_WechatSession];
    }
}
- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:self completion:^(id result, NSError *error) {
        if (!error) {
            NSString * cmd;
            if (platformType == UMSocialPlatformType_WechatSession) {
                cmd = @"U100";
            }else if (platformType == UMSocialPlatformType_QQ)
            {
                cmd = @"U101";
            }
            UMSocialUserInfoResponse *resp = result;
            NSDictionary *headDic = @{
                                      @"cmd":cmd
                                      };
            NSDictionary *bodyDic_ = @{
                                      @"openId":resp.openid,
                                      @"nickName":resp.name,
                                      @"headImage":resp.iconurl,
                                      };
            NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
            if (!DRStringIsEmpty(resp.unionId)) {
                [bodyDic setObject:resp.unionId forKey:@"unionId"];
            }
            
            waitingView
            [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
                DRLog(@"%@",json);
                [MBProgressHUD hideHUDForView:self.view];
                if (SUCCESS) {
                    //存储userId和digest
                    [DRUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
                    [DRUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
                    
                    if (DRStringIsEmpty(json[@"phone"])) {//未绑定手机 去绑定
                        DRThirdPartyBindingViewController * thirdPartyBindingVC = [[DRThirdPartyBindingViewController alloc] init];
                        DRBaseNavigationController *nav = [[DRBaseNavigationController alloc]initWithRootViewController:thirdPartyBindingVC];
                        [self presentViewController:nav animated:YES completion:nil];
                    }else
                    {
                        //登录时间
                        [DRUserDefaultTool saveObject:[DRTool getNowTimeTimestamp] forKey:@"lastLoginTime"];
                        
                        [self getShopData];
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                        //登录成功通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
                    }
                    [DRTool loginImAccount];
                }else
                {
                    ShowErrorView
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view];
                DRLog(@"error:%@",error);
            }];
        }else
        {
            NSLog(@" error: %@", error);
        }
    }];
}
#pragma mark - UITextFieldNotification
-(void)textFieldEditChanged:(NSNotification *)notification
{
    if(self.accountTF.text.length != 0 && self.passwordTF.text.length != 0)//验证
    {
        self.loginBtn.backgroundColor = DRDefaultColor;
        self.loginBtn.enabled = YES;
    }else
    {
        self.loginBtn.backgroundColor = DRColor(218, 218, 218, 1);
        self.loginBtn.enabled = NO;
    }
}
#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.accountTF];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.passwordTF];
}

@end
