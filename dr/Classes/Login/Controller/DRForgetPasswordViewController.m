//
//  DRForgetPasswordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRForgetPasswordViewController.h"
#import "DRSetupPasswordViewController.h"
#import "DRValidateTool.h"

@interface DRForgetPasswordViewController ()
{
    int oneMinute;
}
@property (nonatomic, weak) UITextField *phoneTF;
@property (nonatomic, weak) UITextField *picCodeTF;
@property (nonatomic, weak) UITextField *phoneCodeTF;
@property (nonatomic, weak) UIImageView * picCodeImageView;
@property (nonatomic, weak) UIButton *phoneCodeBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *timeSp;

@end

@implementation DRForgetPasswordViewController

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
    self.title = @"忘记密码";
    [self setupChilds];
}

#pragma mark - 布局子控件
- (void)setupChilds
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"black_back_bar" highIcon:@"black_back_bar" target:self action:@selector(back)];
    
    NSArray *placeholders = @[@"请输入新手机号码", @"请输入图片验证码", @"请输入验证码"];
    
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH * placeholders.count)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    CGFloat picCodeViewW = 73;
    CGFloat picCodeViewH = 27;
    CGFloat phoneCodeBtnW = 86;
    CGFloat phoneCodeBtnH = 30;
    for (int i = 0; i < placeholders.count; i++) {
        UITextField * textField = [[UITextField alloc] init];
        if (i == 0) {
            self.phoneTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin, DRCellH);
        }else if (i == 1)
        {
            self.picCodeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - picCodeViewW - DRMargin, DRCellH);
        }else if (i == 2)
        {
            self.phoneCodeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - phoneCodeBtnW - DRMargin, DRCellH);
        }
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.textColor = DRBlackTextColor;
        textField.tintColor = DRDefaultColor;
        textField.placeholder = placeholders[i];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [backView addSubview:textField];
        
        //分割线
        if (i != 0) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH * i, screenWidth, 1)];
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
    
    //下一步
    UIButton * nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(backView.frame) + 50, screenWidth - 2 * DRMargin, 40);
    nextButton.backgroundColor = DRDefaultColor;
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = nextButton.height / 2;
    [nextButton addTarget:self action:@selector(nextButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
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

- (void)nextButtonDidClick
{
    if (![DRValidateTool validateMobile:self.phoneTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的手机号格式不对"];
        return;
    }
    
    if (self.phoneCodeTF.text.length == 0)//不是验证码码
    {
        [MBProgressHUD showError:@"您输入的验证码格式不对"];
        return;
    }

    NSDictionary *bodyDic = @{
                              @"code":self.phoneCodeTF.text,
                              @"phone":self.phoneTF.text,
                              };
    NSDictionary *headDic = @{
                              @"cmd":@"U03",
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        if(SUCCESS)
        {
            DRSetupPasswordViewController *setupPasswordVC = [[DRSetupPasswordViewController alloc] init];
            setupPasswordVC.token = json[@"token"];
            setupPasswordVC.userId = json[@"userId"];
            [self.navigationController pushViewController:setupPasswordVC animated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
