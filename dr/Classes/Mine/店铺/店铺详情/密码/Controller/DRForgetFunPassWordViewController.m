//
//  DRForgetFunPassWordViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/11/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRForgetFunPassWordViewController.h"
#import "DRValidateTool.h"

@interface DRForgetFunPassWordViewController ()
{
    int oneMinute;
}
@property (nonatomic, weak) UITextField * phoneTF;
@property (nonatomic, weak) UITextField *picCodeTF;
@property (nonatomic, weak) UITextField *codeTF;
@property (nonatomic, weak) UITextField * passwordTF;
@property (nonatomic, weak) UIImageView * picCodeImageView;
@property (nonatomic, weak) UIButton *codeBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *timeSp;

@end

@implementation DRForgetFunPassWordViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.codeBtn.enabled = YES;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.timer invalidate];
    self.timer = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"重置提款密码";
    [self setupChilds];
}
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    NSArray *placeholders = @[@"请输入手机号", @"请输入图片验证码", @"请输入验证码", @"设置新密码，6-20位字母、数字组合"];
    
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH * placeholders.count)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    CGFloat picCodeViewW = 73;
    CGFloat picCodeViewH = 27;
    CGFloat codeBtnW = 86;
    CGFloat codeBtnH = 30;
    for (int i = 0; i < placeholders.count; i++) {
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin, DRCellH)];
        if (i == 0) {
            self.phoneTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 1)
        {
            self.picCodeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - picCodeViewW - DRMargin, DRCellH);
        }else if (i == 2)
        {
            self.codeTF = textField;
            textField.frame = CGRectMake(DRMargin, DRCellH * i, screenWidth -  2 * DRMargin - codeBtnW - DRMargin, DRCellH);
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else
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
    UIButton * codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.codeBtn = codeBtn;
    codeBtn.frame = CGRectMake(screenWidth - codeBtnW - DRMargin, DRCellH * 2 + (DRCellH - codeBtnH) / 2, codeBtnW, codeBtnH);
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [codeBtn addTarget:self action:@selector(getphoneCodeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    codeBtn.layer.masksToBounds = YES;
    codeBtn.layer.cornerRadius = codeBtn.height / 2;
    codeBtn.layer.borderColor = DRDefaultColor.CGColor;
    codeBtn.layer.borderWidth = 1;
    [backView addSubview:codeBtn];
    
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
    [self.view endEditing:YES];
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的手机号格式不对"];
        return;
    }
    
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
            self.codeBtn.enabled = YES;
            [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
            [self.timer invalidate];
            self.timer = nil;
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showError:@"获取验证码失败"];
        //倒计时失效
        self.codeBtn.enabled = YES;
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
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
    self.codeBtn.enabled = NO;
    if(oneMinute > 0)
    {
        oneMinute--;
        [self.codeBtn setTitle:[NSString stringWithFormat:@"%d秒",oneMinute] forState:UIControlStateNormal];
    }else
    {
        self.codeBtn.enabled = YES;
        [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (![DRValidateTool validateMobile:self.phoneTF.text])//不是手机号码
    {
        [MBProgressHUD showError:@"您输入的手机号格式不对"];
        return;
    }
    if (DRStringIsEmpty(self.codeTF.text))//没有输入验证码
    {
        [MBProgressHUD showError:@"您还未输入验证码"];
        return;
    }
    if (![DRValidateTool validatePassword:self.passwordTF.text])//不是密码
    {
        [MBProgressHUD showError:@"您输入的密码格式不对"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"phone":self.phoneTF.text,
                              @"code":self.codeTF.text,
                              @"password":self.passwordTF.text,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U52",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"重置成功"];
            [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
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
