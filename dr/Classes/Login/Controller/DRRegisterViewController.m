//
//  DRRegisterViewController.m
//  dr
//
//  Created by apple on 17/2/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRRegisterViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "UIBarButtonItem+DR.h"
#import "DRValidateTool.h"

@interface DRRegisterViewController ()
{
    int oneMinute;
}
@property (nonatomic, weak) UITextField *phoneTF;
@property (nonatomic, weak) UITextField *picCodeTF;
@property (nonatomic, weak) UITextField *phoneCodeTF;
@property (nonatomic, weak) UIImageView * picCodeImageView;
@property (nonatomic, weak) UIButton *phoneCodeBtn;
@property (nonatomic, weak) UITextField * passwordTF;
@property (nonatomic, weak) UIButton *agreementSeletedBtn;
@property (nonatomic, weak) UIButton * registerBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *timeSp;

@end

@implementation DRRegisterViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.phoneCodeBtn.enabled = YES;
    [self.phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"注册";
    [self setupChilds];
}

#pragma mark - 布局子控件
- (void)setupChilds
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"black_back_bar" highIcon:@"black_back_bar" target:self action:@selector(back)];
    
    NSArray *placeholders = @[@"请输入新手机号码", @"请输入图片验证码", @"请输入验证码", @"请输入密码"];
    
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH * placeholders.count)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
  
    CGFloat picCodeViewW = 73;
    CGFloat picCodeViewH = 27;
    CGFloat phoneCodeBtnW = 86;
    CGFloat phoneCodeBtnH = 30;
    for (int i = 0; i < placeholders.count; i++) {
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin, DRCellH)];
        if (i == 0) {
            self.phoneTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 1)
        {
            self.picCodeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - picCodeViewW - DRMargin, DRCellH);
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 2)
        {
            self.phoneCodeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - phoneCodeBtnW - DRMargin, DRCellH);
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 3)
        {
            self.passwordTF = textField;
            textField.secureTextEntry = YES;
        }
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.textColor = DRBlackTextColor;
        textField.tintColor = DRDefaultColor;
        textField.placeholder = placeholders[i];
        [backView addSubview:textField];
        
        //分割线
        if (i != 0) {
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, DRCellH * i, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [backView addSubview:line];
        }
    }
    
    //图片验证码
    UIImageView * picCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - picCodeViewW - DRMargin, DRCellH + (DRCellH - picCodeViewH) / 2, picCodeViewW, picCodeViewH)];
    self.picCodeImageView = picCodeImageView;
    [backView addSubview:picCodeImageView];
    [self getPicCode];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getPicCode)];
    picCodeImageView.userInteractionEnabled = YES;
    [picCodeImageView addGestureRecognizer:tap];
    
    //获取验证吗按钮
    UIButton * phoneCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.phoneCodeBtn = phoneCodeBtn;
    phoneCodeBtn.frame = CGRectMake(screenWidth - phoneCodeBtnW - DRMargin, DRCellH * 2 + (DRCellH - phoneCodeBtnH) / 2, phoneCodeBtnW, phoneCodeBtnH);
    [phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [phoneCodeBtn setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    phoneCodeBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [phoneCodeBtn addTarget:self action:@selector(getphoneCodeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    phoneCodeBtn.layer.masksToBounds = YES;
    phoneCodeBtn.layer.cornerRadius = phoneCodeBtn.height / 2;
    phoneCodeBtn.layer.borderColor = DRDefaultColor.CGColor;
    phoneCodeBtn.layer.borderWidth = 1;
    [backView addSubview:phoneCodeBtn];

    //注册按钮
    UIButton * registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerBtn = registerBtn;
    registerBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(backView.frame) + 50, screenWidth - 2 * DRMargin, 40);
    registerBtn.backgroundColor = DRDefaultColor;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    registerBtn.layer.masksToBounds = YES;
    registerBtn.layer.cornerRadius = registerBtn.height / 2;
    [registerBtn addTarget:self action:@selector(registerBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];
    
    //协议
    UIButton *agreementSeletedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.agreementSeletedBtn = agreementSeletedBtn;
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateHighlighted];
    agreementSeletedBtn.selected = YES;
    agreementSeletedBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(registerBtn.frame) + 7, 20, 20);
    [agreementSeletedBtn addTarget:self action:@selector(agreementSeletedBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreementSeletedBtn];
    
    UILabel *agreementLabel = [[UILabel alloc] init];
    agreementLabel.text = @"我已阅读并同意";
    agreementLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    agreementLabel.textAlignment = NSTextAlignmentLeft;
    agreementLabel.textColor = DRGrayTextColor;
    CGSize agreementLabelSize = [agreementLabel.text sizeWithLabelFont:agreementLabel.font];
    agreementLabel.frame = CGRectMake(CGRectGetMaxX(agreementSeletedBtn.frame) + 3, agreementSeletedBtn.y, agreementLabelSize.width, 20);
    [self.view addSubview:agreementLabel];
    
    UIButton *agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn setTitle:@"用户协议" forState:UIControlStateNormal];
    [agreementBtn setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    agreementBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize megBtnSize = [agreementBtn.currentTitle sizeWithLabelFont:agreementBtn.titleLabel.font];
    agreementBtn.frame = CGRectMake(CGRectGetMaxX(agreementLabel.frame), agreementSeletedBtn.y, megBtnSize.width, 20);
    [agreementBtn addTarget:self action:@selector(seeAgreement) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreementBtn];
}

- (void)agreementSeletedBtnDidClick:(UIButton *)button
{
    button.selected = !button.selected;
}

- (void)seeAgreement
{
    DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@/static/about.html", baseUrl]];
    [self.navigationController pushViewController:htmlVC animated:YES];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getPicCode
{
    self.timeSp = [DRTool getNowTimeTimestamp];
    NSString * urlStr = [NSString stringWithFormat:@"%@/jshop/verify.html?code=%@", baseUrl, self.timeSp];
    [self.picCodeImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:self.picCodeImageView.image];
}

- (void)getphoneCodeBtnPressed
{
    [self.view endEditing:YES];
    
    if (self.picCodeTF.text.length == 0)//不是验证码码
    {
        [MBProgressHUD showError:@"您输入的图片验证码格式不对"];
        return;
    }
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的手机号格式不对"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"code":self.timeSp,
                              @"codeValue":self.picCodeTF.text
                              };
    NSDictionary *headDic = @{
                              @"cmd":@"U99",
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        if(SUCCESS)
        {
            [self getPhoneCode];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showError:@"获取验证码失败"];
    }];
}

- (void)getPhoneCode
{
    NSDictionary *bodyDic = @{
                              @"phone":self.phoneTF.text,
                              @"code":self.timeSp,
                              @"codeValue":self.picCodeTF.text,
                              };
    NSDictionary *headDic = @{
                              @"cmd":@"U05",
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        if(SUCCESS)
        {
            //倒计时
            [self countDown];
        }else
        {
            ShowErrorView
            //倒计时失效
            self.phoneCodeBtn.enabled = YES;
            [self.phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.timer invalidate];
            self.timer = nil;
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showError:@"获取验证码失败"];
        //倒计时失效
        self.phoneCodeBtn.enabled = YES;
        [self.phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }];
}

- (void)countDown
{
    if (!self.timer) {
        oneMinute = 60;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextSecond) userInfo:nil repeats:YES];
        self.timer =timer;
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)nextSecond
{
    self.phoneCodeBtn.enabled = NO;
    DRLog(@"%d",oneMinute);
    if(oneMinute > 0)
    {
        oneMinute--;
        [self.phoneCodeBtn setTitle:[NSString stringWithFormat:@"%d秒",oneMinute] forState:UIControlStateNormal];
    }else
    {
        self.phoneCodeBtn.enabled = YES;
        [self.phoneCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - 按钮点击
- (void)registerBtnDidClick:(UIButton *)button
{
    [self.view endEditing:YES];
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的手机号格式不对"];
        return;
    }
    if (DRStringIsEmpty(self.phoneCodeTF.text))//没有输入验证码
    {
        [MBProgressHUD showError:@"您还未输入验证码"];
        return;
    }
    if (![DRValidateTool validatePassword:self.passwordTF.text])//不是密码
    {
        [MBProgressHUD showError:@"您输入的密码格式不对"];
        return;
    }
    if (!self.agreementSeletedBtn.selected)
    {
        [MBProgressHUD showError:@"您还未同意用户协议"];
        return;
    }
    
    NSDictionary *headDic = @{
                              @"cmd":@"U01"
                             };
    NSDictionary *bodyDic = @{
                              @"phone":self.phoneTF.text,
                              @"password":self.passwordTF.text,
                              @"code":self.phoneCodeTF.text
                              };
    self.registerBtn.enabled = NO;
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        self.registerBtn.enabled = YES;
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"注册成功"];
            //存储login_name
            [DRUserDefaultTool saveObject:self.phoneTF.text forKey:@"login_name"];
            
            //存储userId和digest
            [DRUserDefaultTool saveObject:json[@"userId"] forKey:@"userId"];
            [DRUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
    
            //登录时间
            [DRUserDefaultTool saveObject:[DRTool getNowTimeTimestamp] forKey:@"lastLoginTime"];
            
            [DRTool loginImAccount];
            
            //登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            
            //返回上上页面
            UIViewController *rootVC = self.presentingViewController;
            while (rootVC.presentingViewController) {
                rootVC = rootVC.presentingViewController;
            }
            [rootVC dismissViewControllerAnimated:YES completion:nil];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        self.registerBtn.enabled = YES;
    }];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
