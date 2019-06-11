//
//  DRMailSettingViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/16.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRMailSettingViewController.h"
#import "DRPinkageSettingViewController.h"
#import "DRMailSettingModel.h"

@interface DRMailSettingViewController ()<PinkageSettingDelegate>

@property (nonatomic, weak) UIView * mailSettingView;
@property (nonatomic, weak) UITextField * mailSettingTF;
@property (nonatomic, weak) UIView * mailMoneyView;
@property (nonatomic, weak) UITextField * mailMoneyTF;
@property (nonatomic, weak) UILabel * promptLabel;
@property (nonatomic, weak) UIButton * confirmButton;
@property (nonatomic, strong) DRMailSettingModel *mailSettingModel;

@end

@implementation DRMailSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"运费设置";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B15",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.mailSettingModel = [DRMailSettingModel mj_objectWithKeyValues:json];
            [self setData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

- (void)setData
{
    double moneyF = [self.mailSettingModel.ruleMoney doubleValue];
    if (moneyF == 0) {
        self.mailSettingTF.text = @"包邮";
        self.mailMoneyTF.text = @"";
        self.mailMoneyView.hidden = YES;
        self.promptLabel.hidden = YES;
        self.confirmButton.y = CGRectGetMaxY(self.mailSettingView.frame) + 29;
    }else
    {
        self.mailSettingTF.text = [NSString stringWithFormat:@"满%@包邮", [DRTool formatFloat:moneyF / 100]];
        self.mailMoneyTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.mailSettingModel.freight doubleValue] / 100]];
        self.mailMoneyView.hidden = NO;
        self.promptLabel.hidden = NO;
        self.confirmButton.y = CGRectGetMaxY(self.promptLabel.frame) + 29;
    }
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //设置运费
    UIView * mailSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    self.mailSettingView = mailSettingView;
    mailSettingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mailSettingView];
    
    UILabel * mailSettingLabel = [[UILabel alloc] init];
    mailSettingLabel.text = @"包邮设置";
    mailSettingLabel.textColor = DRBlackTextColor;
    mailSettingLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize mailSettingLabelSize = [mailSettingLabel.text sizeWithLabelFont:mailSettingLabel.font];
    mailSettingLabel.frame = CGRectMake(DRMargin, 0, mailSettingLabelSize.width, DRCellH);
    [mailSettingView addSubview:mailSettingLabel];
    
    UITextField * mailSettingTF = [[UITextField alloc] init];
    self.mailSettingTF = mailSettingTF;
    CGFloat mailSettingTFX = CGRectGetMaxX(mailSettingLabel.frame) + DRMargin;
    mailSettingTF.frame = CGRectMake(mailSettingTFX, 0, screenWidth - mailSettingTFX - DRMargin - 7, DRCellH);
    mailSettingTF.textColor = DRBlackTextColor;
    mailSettingTF.textAlignment = NSTextAlignmentRight;
    mailSettingTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    mailSettingTF.tintColor = DRDefaultColor;
    mailSettingTF.placeholder = @"未设置";
    mailSettingTF.userInteractionEnabled = NO;
    [mailSettingView addSubview:mailSettingTF];
    
    UIButton *mailSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mailSettingBtn.frame =  CGRectMake(mailSettingTFX, 0, screenWidth - mailSettingTFX, DRCellH);
    [mailSettingBtn setImageEdgeInsets:UIEdgeInsetsMake(0, mailSettingBtn.width - DRMargin - 10, 0, 0)];
    [mailSettingBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
    [mailSettingBtn addTarget:self action:@selector(mailSettingBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [mailSettingView addSubview:mailSettingBtn];

    //运费
    UIView * mailMoneyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(mailSettingView.frame) + 9, screenWidth, DRCellH)];
    self.mailMoneyView = mailMoneyView;
    mailMoneyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mailMoneyView];
    
    UILabel * mailMoneyLabel = [[UILabel alloc] init];
    mailMoneyLabel.text = @"运费";
    mailMoneyLabel.textColor = DRBlackTextColor;
    mailMoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize mailMoneyLabelSize = [mailMoneyLabel.text sizeWithLabelFont:mailMoneyLabel.font];
    mailMoneyLabel.frame = CGRectMake(DRMargin, 0, mailMoneyLabelSize.width, DRCellH);
    [mailMoneyView addSubview:mailMoneyLabel];
    
    UITextField * mailMoneyTF = [[UITextField alloc] init];
    self.mailMoneyTF = mailMoneyTF;
    CGFloat mailMoneyTFX = CGRectGetMaxX(mailMoneyLabel.frame) + DRMargin;
    mailMoneyTF.frame = CGRectMake(mailMoneyTFX, 0, screenWidth - mailMoneyTFX - DRMargin, DRCellH);
    mailMoneyTF.textColor = DRBlackTextColor;
    mailMoneyTF.textAlignment = NSTextAlignmentRight;
    mailMoneyTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    mailMoneyTF.tintColor = DRDefaultColor;
    mailMoneyTF.keyboardType = UIKeyboardTypeNumberPad;
    mailMoneyTF.placeholder = @"请输入运费";
    [mailMoneyView addSubview:mailMoneyTF];
    
    //提示
    UILabel * promptLabel = [[UILabel alloc]init];
    self.promptLabel = promptLabel;
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"*当买家不满足包邮条件时，将使用上述运费";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [promptAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(mailMoneyView.frame) + 10, screenWidth - DRMargin * 2, promptSize.height);
    [self.view addSubview:promptLabel];
    
    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton = confirmButton;
    confirmButton.frame = CGRectMake(15, CGRectGetMaxY(promptLabel.frame) + 29, screenWidth - 30, 40);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = confirmButton.height / 2;
    [self.view addSubview:confirmButton];
}

- (void)mailSettingBtnDidClick
{
    DRPinkageSettingViewController * pinkageSettingVC = [[DRPinkageSettingViewController alloc] init];
    pinkageSettingVC.delegate = self;
    pinkageSettingVC.ruleMoney = self.mailSettingModel.ruleMoney;
    [self.navigationController pushViewController:pinkageSettingVC animated:YES];
}

- (void)pinkageSettingSuccessWithMoney:(NSNumber *)money
{
    self.mailSettingModel.ruleMoney = money;
    [self setData];
}

- (void)confirmButtonDidClick
{
    [self.view endEditing:YES];
    
    double freightF = [self.mailMoneyTF.text intValue];
    if ([self.mailSettingModel.ruleMoney doubleValue] > 0 && freightF == 0) {
        [MBProgressHUD showError:@"邮费不能为0元"];
        return;
    }
    
    NSNumber * freight = @(freightF * 100);
    if ([self.mailSettingModel.ruleMoney doubleValue] == 0) {
        freight = @(0);
    }
    NSDictionary *bodyDic = @{
                              @"freight":freight
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"C13",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"设置成功"];
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
