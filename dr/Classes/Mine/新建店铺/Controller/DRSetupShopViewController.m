//
//  DRSetupShopViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSetupShopViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRTextView.h"
#import "DRAddImageManage.h"

@interface DRSetupShopViewController ()<AddImageManageDelegate>

@property (nonatomic, strong) DRAddImageManage * addImageManage;
@property (nonatomic, weak) UIImageView *logoImageView;//logo
@property (nonatomic, weak) UITextField *shopNameTF;//店名输入框
@property (nonatomic, weak) UITextField *shopAddressTF;
@property (nonatomic, weak) DRTextView *shopDescriptionTV;//店铺简介输入
@property (nonatomic, weak) UIButton *agreementSeletedBtn;

@end

@implementation DRSetupShopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我要开店";
    [self setupChilds];
}

- (void)setupChilds
{
    //contentView
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    //logo
    CGFloat logoWH = 65;
    CGFloat logoImageViewX = (screenWidth - logoWH) / 2;
    UIImageView * logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(logoImageViewX, 30, logoWH, logoWH)];
    self.logoImageView = logoImageView;
    logoImageView.image = [UIImage imageNamed:@"logo_default"];
    [contentView addSubview:logoImageView];
    
    logoImageView.layer.masksToBounds = YES;
    logoImageView.layer.cornerRadius = logoWH / 2;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addLogo)];
    logoImageView.userInteractionEnabled = YES;
    [logoImageView addGestureRecognizer:tap];
    
    //店铺名称
    UITextField * shopNameTF = [[UITextField alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(logoImageView.frame) + 30, screenWidth -  2 * DRMargin, DRCellH)];
    self.shopNameTF = shopNameTF;
    shopNameTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopNameTF.textColor = DRBlackTextColor;
    shopNameTF.placeholder = @"给店铺起个好听的名字的吧";
    shopNameTF.tintColor = DRDefaultColor;
    [contentView addSubview:shopNameTF];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(shopNameTF.frame), screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    //店铺地址
    UITextField * shopAddressTF = [[UITextField alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line1.frame), screenWidth -  2 * DRMargin, DRCellH)];
    self.shopAddressTF = shopAddressTF;
    shopAddressTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopAddressTF.textColor = DRBlackTextColor;
    shopAddressTF.placeholder = @"输入店铺的详细地址";
    shopAddressTF.tintColor = DRDefaultColor;
    [contentView addSubview:shopAddressTF];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(shopAddressTF.frame), screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line2];
    
    //店铺简介
    DRTextView *shopDescriptionTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(line2.frame), screenWidth - 2 * 5, 100)];
    self.shopDescriptionTV = shopDescriptionTV;
    shopDescriptionTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopDescriptionTV.textColor = DRBlackTextColor;
    shopDescriptionTV.myPlaceholder = @"用100个字介绍一下您的店铺吧";
    shopDescriptionTV.maxLimitNums = 100;
    shopDescriptionTV.tintColor = DRDefaultColor;
    [contentView addSubview:shopDescriptionTV];
    
    contentView.height = CGRectGetMaxY(shopDescriptionTV.frame) + 10;
    
    //开店
    UIButton * nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame) + 50, screenWidth - 2 * DRMargin, 40);
    nextButton.backgroundColor = DRDefaultColor;
    [nextButton setTitle:@"开店" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = nextButton.height / 2;
    [nextButton addTarget:self action:@selector(nextButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    //协议
    UIButton *agreementSeletedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.agreementSeletedBtn = agreementSeletedBtn;
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [agreementSeletedBtn setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateHighlighted];
    agreementSeletedBtn.selected = YES;
    agreementSeletedBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(nextButton.frame) + 7, 20, 20);
    [agreementSeletedBtn addTarget:self action:@selector(agreementSeletedBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreementSeletedBtn];
    
    UILabel *agreementLabel = [[UILabel alloc] init];
    agreementLabel.text = @"我已阅读";
    agreementLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    agreementLabel.textAlignment = NSTextAlignmentLeft;
    agreementLabel.textColor = DRGrayTextColor;
    CGSize agreementLabelSize = [agreementLabel.text sizeWithLabelFont:agreementLabel.font];
    agreementLabel.frame = CGRectMake(CGRectGetMaxX(agreementSeletedBtn.frame) + 3, agreementSeletedBtn.y, agreementLabelSize.width, 20);
    [self.view addSubview:agreementLabel];
    
    UIButton *agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn setTitle:@"开店须知" forState:UIControlStateNormal];
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
    DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@/static/kaidian.html", baseUrl]];
    [self.navigationController pushViewController:htmlVC animated:YES];
}

//添加图片
- (void)addLogo
{
    self.addImageManage = [[DRAddImageManage alloc] init];
    self.addImageManage.viewController = self;
    self.addImageManage.delegate = self;
    self.addImageManage.type = 1;
    [self.addImageManage addImage];
}

- (void)imageManageCropImage:(UIImage *)image
{
    self.logoImageView.image = image;
}

- (void)nextButtonDidClick
{
    [self.view endEditing:YES];
    
    if (self.logoImageView.image == [UIImage imageNamed:@"logo_default"]) {
        [MBProgressHUD showError:@"请选择店铺头像"];
        return;
    }
    
    NSString * addressStr = [NSString stringWithFormat:@"%@", self.shopAddressTF.text];
    if (DRStringIsEmpty(self.shopNameTF.text))
    {
        [MBProgressHUD showError:@"您还输入店铺名称"];
        return;
    }
    if (DRStringIsEmpty(self.shopAddressTF.text))
    {
        [MBProgressHUD showError:@"您还未输入店铺详细地址"];
        return;
    }
    if (DRStringIsEmpty(self.shopDescriptionTV.text))
    {
        [MBProgressHUD showError:@"您还未输入店铺简介"];
        return;
    }
    if ([DRTool stringContainsEmoji:self.shopNameTF.text] || [DRTool stringContainsEmoji:self.shopDescriptionTV.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    if (!self.agreementSeletedBtn.selected)
    {
        [MBProgressHUD showError:@"您还未同意开店须知"];
        return;
    }
    NSString * image64 = [DRTool stringByimageBase64WithImage:self.logoImageView.image];
    waitingView;
    NSDictionary *bodyDic = @{
                              @"address":addressStr,
                              @"name":self.shopNameTF.text,
                              @"logo":image64,
                              @"description":self.shopDescriptionTV.text,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U50",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:json[@"message"]];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setupShopSuccess" object:nil];
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
