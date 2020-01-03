//
//  DRAddShowSuccessViewController.m
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRAddShowSuccessViewController.h"
#import "DRShowViewController.h"
#import "DRShareTool.h"
#import "DRShowModel.h"

@interface DRAddShowSuccessViewController ()

@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic, weak) UILabel * moneyLabel;
@property (nonatomic, weak) UIImageView * activityImageView;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation DRAddShowSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发布成功";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
    [self judgePraiseActivity];
}

- (void)judgePraiseActivity
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G12",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            UIView * lastView;
            if ([json[@"activityStatus"] intValue] == 1) {
                self.activityImageView.hidden = NO;
                lastView = self.activityImageView;
            }else
            {
                self.activityImageView.hidden = YES;
                lastView = self.moneyLabel;
            }
            for (UIButton * button in self.buttons) {
                button.y = CGRectGetMaxY(lastView.frame) + 40;
                self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(button.frame) + 10);
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"black_back_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    //对号
    CGFloat paySuccessImageViewWH = 43;
    UIImageView * paySuccessImageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth - paySuccessImageViewWH) / 2, 80, paySuccessImageViewWH, paySuccessImageViewWH)];
    paySuccessImageView.image = [UIImage imageNamed:@"pay_success_icon"];
    [scrollView addSubview:paySuccessImageView];
    
    //金额
    UILabel * moneyLabel = [[UILabel alloc] init];
    self.moneyLabel = moneyLabel;
    moneyLabel.text = @"发布成功";
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(45)];
    moneyLabel.textColor = DRDefaultColor;
    CGSize moneyLabelSize = [moneyLabel.text sizeWithLabelFont:moneyLabel.font];
    moneyLabel.frame = CGRectMake((screenWidth - moneyLabelSize.width) / 2, CGRectGetMaxY(paySuccessImageView.frame) + 30, moneyLabelSize.width, moneyLabelSize.height);
    [scrollView addSubview:moneyLabel];
    
    //提示
    CGFloat activityImageViewW = screenWidth;
    CGFloat activityImageViewH = activityImageViewW / 375 * 150;
    UIImageView * activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(moneyLabel.frame) + 30, activityImageViewW, activityImageViewH)];
    self.activityImageView = activityImageView;
    activityImageView.image = [UIImage imageNamed:@"show_praise_banner"];
    activityImageView.hidden = YES;
    [scrollView addSubview:activityImageView];
    
    //按钮
    CGFloat buttonW = 118;
    CGFloat buttonH = 39;
    CGFloat buttonY = CGRectGetMaxY(activityImageView.frame) + 40;
    CGFloat paddingButton = 60;
    CGFloat padding = (screenWidth - 2 * buttonW - paddingButton) / 2;
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(padding + (buttonW + paddingButton) * i, buttonY, buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"分享好友" forState:UIControlStateNormal];
            [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
            button.layer.borderColor = DRDefaultColor.CGColor;
        }else
        {
            [button setTitle:@"返回首页" forState:UIControlStateNormal];
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            button.layer.borderColor = DRGrayLineColor.CGColor;
        }
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonH / 2;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        [self.buttons addObject:button];
        
        scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(button.frame) + 10);
    }
}

- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) {
        [self shareBarDidClick];
    }else
    {
        [self back];
    }
}

- (void)back
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddShowSuccess" object:nil];
    
    UIViewController * praiseListVC = nil;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[DRShowViewController class]]) {
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
}

- (void)shareBarDidClick
{
    NSDictionary *bodyDic = @{
                              @"id":self.showId
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"A04",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShowModel *showModel = [DRShowModel mj_objectWithKeyValues:json[@"article"]];
            NSArray * imageUrls = [showModel.pics componentsSeparatedByString:@"|"];
            [DRShareTool shareShowWithShowId:showModel.id userNickName:showModel.userNickName title:showModel.name content:showModel.content imageUrl:[NSString stringWithFormat:@"%@%@%@", baseUrl, imageUrls.firstObject, smallPicUrl]];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
