//
//  DRUserShowViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRUserShowViewController.h"
#import "DRLoginViewController.h"
#import "DRShowTableView.h"
#import "IQKeyboardManager.h"

@interface DRUserShowViewController ()<ShowTableViewDelegate>

@property (nonatomic, weak) DRShowTableView* showTableView;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic,weak) UIImageView *barAvatarImageView;
@property (nonatomic, weak) UILabel * barNickNameLabel;
@property (nonatomic, weak) UIButton * backButon;
@property (nonatomic, weak) UIButton * attentionButton;

@end

@implementation DRUserShowViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollViewDidScroll:self.showTableView];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = NO;
    keyboardManager.enable = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = YES;
    keyboardManager.enable = YES;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
    if (@available(iOS 11.0, *)) {
        self.showTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self getAttentionData];
}

- (void)getAttentionData
{
    if(!UserId || !Token)
    {
        return;
    }

    NSDictionary *bodyDic = @{
                              @"id":self.userId,
                              @"type":@(3)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U25",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.attentionButton.selected = [json[@"focus"] boolValue];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    CGFloat viewH = screenHeight;
    DRShowTableView* showTableView = [[DRShowTableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, viewH) style:UITableViewStyleGrouped userId:self.userId type:@(1) topY:0];
    self.showTableView = showTableView;
    showTableView.showDelegate = self;
    [self.view addSubview:showTableView];
    [showTableView setupChilds];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(200))];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIImageView * backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(200))];
    if (iPhone4 || iPhone5)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_320"];
    }else if (iPhone6 || iPhoneX)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }else if (iPhone6P || iPhoneXR || iPhoneXSMax)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_414"];
    }else
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }
    backImageView.userInteractionEnabled = YES;
    [headerView addSubview:backImageView];
    
    //barView
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)];
    self.barView = barView;
    barView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self.view addSubview:barView];
    
    UILabel *barNickNameLabel = [[UILabel alloc] init];
    self.barNickNameLabel = barNickNameLabel;
    barNickNameLabel.textColor = DRBlackTextColor;
    barNickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    barNickNameLabel.text = self.nickName;
    [barView addSubview:barNickNameLabel];
    
    UIImageView * barAvatarImageView = [[UIImageView alloc] init];
    self.barAvatarImageView = barAvatarImageView;
    barAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    barAvatarImageView.layer.masksToBounds = YES;
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,self.userHeadImg];
    [barAvatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    [barView addSubview:barAvatarImageView];
    
    CGSize barNickNameLabelSize = [barNickNameLabel.text sizeWithLabelFont:barNickNameLabel.font];
    CGFloat barAvatarImageViewWH = 35;
    CGFloat barAvatarImageViewX = (screenWidth - barAvatarImageViewWH - barNickNameLabelSize.width - 2) / 2;
    barAvatarImageView.frame = CGRectMake(barAvatarImageViewX, statusBarH + (navBarH - barAvatarImageViewWH) / 2, barAvatarImageViewWH, barAvatarImageViewWH);
    barAvatarImageView.layer.cornerRadius = barAvatarImageView.width / 2;
    barNickNameLabel.frame = CGRectMake(CGRectGetMaxX(barAvatarImageView.frame) + 2, statusBarH, barNickNameLabelSize.width, navBarH);
    
    //返回
    UIButton * backButon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButon = backButon;
    backButon.frame = CGRectMake(5, statusBarH + 6, 34, 30);
    [backButon setImage:[UIImage imageNamed:@"white_back_bar"] forState:UIControlStateNormal];
    [backButon addTarget:self action:@selector(backButonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backButon];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 55) / 2, 70, 55, 55)];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    avatarImageView.layer.borderWidth = 3;
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    [backImageView addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.text = self.nickName;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.frame = CGRectMake(0, CGRectGetMaxY(avatarImageView.frame) + 12, backImageView.width, nickNameLabel.font.lineHeight);
    [backImageView addSubview:nickNameLabel];
    
    UIButton * attentionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.attentionButton = attentionButton;
    [attentionButton setTitle:@"+关注" forState:UIControlStateNormal];
    [attentionButton setTitle:@"已关注" forState:UIControlStateSelected];
    CGFloat buttonW = 65;
    CGFloat buttonH = 24;
    attentionButton.frame = CGRectMake((screenWidth - buttonW) / 2, CGRectGetMaxY(nickNameLabel.frame) + 13, buttonW, buttonH);
    [attentionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    attentionButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    attentionButton.layer.masksToBounds = YES;
    attentionButton.layer.cornerRadius = buttonH / 2;
    attentionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    attentionButton.layer.borderWidth = 1;
    [attentionButton addTarget:self action:@selector(attentionButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [backImageView addSubview:attentionButton];
    
    showTableView.tableHeaderView = headerView;
}

- (void)attentionButtonDidClick
{
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }

    NSString * cmd;
    if (self.attentionButton.selected) {//取消关注
        cmd = @"U23";
    }else//添加关注
    {
        cmd = @"U22";
    }
    NSDictionary *bodyDic = @{
                              @"id":self.userId,
                              @"type":@(3)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":cmd,
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [self getAttentionData];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)backButonDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.showTableView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat scale = offsetY / 100.0;
        scale = scale > 1 ? 1 : scale;
        self.barAvatarImageView.alpha = scale;
        self.barNickNameLabel.alpha = scale;
        //设置bar背景色
        self.barView.backgroundColor = [UIColor colorWithWhite:1 alpha:scale];
        if (offsetY <= 100) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [self.backButon setImage:[UIImage imageNamed:@"white_back_bar"] forState:UIControlStateNormal];
        }else
        {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            [self.backButon setImage:[UIImage imageNamed:@"black_back_bar"] forState:UIControlStateNormal];
        }
    }
}


@end
