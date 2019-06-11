//
//  DRMineTableHeaderView.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMineTableHeaderView.h"
#import "UIButton+DR.h"

@interface DRMineTableHeaderView ()

@property (nonatomic,weak) UIView * avatarView;
@property (nonatomic, weak) UIImageView *avatarImageView;//头像
@property (nonatomic, weak) UILabel * nameLabel;//用户名
@property (nonatomic, strong) NSMutableArray *moneyDetailbtns;

@end

@implementation DRMineTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"upDataUserNickName" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"upDataUserAvatar" object:nil];
    }
    return self;
}
- (void)setupChildViews
{
    UIImageView * backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, scaleScreenWidth(177))];
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
    [self addSubview:backImageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userInfoDidClick)];
    backImageView.userInteractionEnabled = YES;
    [backImageView addGestureRecognizer:tap];
    
//    //设置
//    UIButton * settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    settingButton.frame = CGRectMake(screenWidth - 7 - 32, statusBarH + 6, 32, 32);
//    [settingButton setImage:[UIImage imageNamed:@"white_setting_bar"] forState:UIControlStateNormal];
//    [settingButton addTarget:self action:@selector(settingButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:settingButton];

    //头像
    UIView * avatarView = [[UIView alloc]initWithFrame:CGRectMake(DRMargin - 3, 82 - 3, 55 + 2 * 3, 55 + 2 * 3)];
    self.avatarView = avatarView;
    avatarView.layer.masksToBounds = YES;
    avatarView.layer.cornerRadius = avatarView.width / 2;
    avatarView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    avatarView.layer.borderWidth = 3;
    [backImageView addSubview:avatarView];
    
    UIImageView * avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 55, 55)];
    self.avatarImageView = avatarImageView;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [avatarView addSubview:avatarImageView];
    
    //用户名
    UILabel * nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [backImageView addSubview:nameLabel];
    
    //accessory
    UIImageView * accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.image = [UIImage imageNamed:@"white_accessory_icon"];
    accessoryImageView.frame = CGRectMake(screenWidth - DRMargin - 10, 0, 10, 16);
    accessoryImageView.centerY = avatarView.centerY;
    [backImageView addSubview:accessoryImageView];
    
    //金额
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(screenWidth * i / 3, CGRectGetMaxY(backImageView.frame), screenWidth / 3, 60);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.numberOfLines = 2;
        if (i == 0) {
            [button setAttributedTitle:[self setAttributedString:[[NSMutableAttributedString alloc] initWithString:@"0.0\n肉币"]] forState:UIControlStateNormal];
        }else if (i == 1) {
            [button setAttributedTitle:[self setAttributedString:[[NSMutableAttributedString alloc] initWithString:@"0个\n红包"]] forState:UIControlStateNormal];
        }else if (i == 2) {
            [button setAttributedTitle:[self setAttributedString: [[NSMutableAttributedString alloc] initWithString:@"0个\n红包"]] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(butonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.moneyDetailbtns addObject:button];
    }
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 9, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
}
//点击用户信息
- (void)userInfoDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewDidClickUserInfo)]) {
        [_delegate headerViewDidClickUserInfo];
    }
}
//点击设置按钮
- (void)settingButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewSettingButtonDidClickUserInfo)]) {
        [_delegate headerViewSettingButtonDidClickUserInfo];
    }
}
//点击金额按钮
- (void)butonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(headerViewDidClickRechargeButton:)]) {
        [_delegate headerViewDidClickRechargeButton:button];
    }
}
- (void)reloadData
{
    DRUser *user = [DRUserDefaultTool user];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.headImg]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    if (DRStringIsEmpty(user.nickName)) {
        self.nameLabel.text = @"您还未设置昵称";
    }else
    {
        self.nameLabel.text = user.nickName;
    }
    
    NSMutableAttributedString * balanceAttStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@\n肉币", [DRTool formatFloat:[user.balance doubleValue] / 100.0]]];
    NSMutableAttributedString * redPacketAttStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@个\n红包", [DRTool  getNumber:user.couponNumber]]];
    NSMutableAttributedString * gradeAttStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d\n积分", 0]];
    for (UIButton * button in self.moneyDetailbtns) {
        NSInteger index = [self.moneyDetailbtns indexOfObject:button];
        if (index == 0) {
            [button setAttributedTitle:[self setAttributedString:balanceAttStr] forState:UIControlStateNormal];
        }else if (index == 1) {
            [button setAttributedTitle:[self setAttributedString:redPacketAttStr] forState:UIControlStateNormal];
        }else if (index == 2) {
            [button setAttributedTitle:[self setAttributedString:gradeAttStr] forState:UIControlStateNormal];
        }
    }
   
    //frame
    CGSize nameLabelSize = [self.nameLabel.text sizeWithLabelFont:self.nameLabel.font];
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 15, 0, nameLabelSize.width, nameLabelSize.height);
    self.nameLabel.centerY = self.avatarView.centerY;
}
- (NSAttributedString *)setAttributedString:(NSMutableAttributedString *)attributedString
{
    [attributedString addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, attributedString.length - 2)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, attributedString.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.alignment = NSTextAlignmentCenter;//居中
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}
#pragma mark - 初始化
- (NSMutableArray *)moneyDetailbtns
{
    if (_moneyDetailbtns == nil) {
        _moneyDetailbtns = [NSMutableArray array];
    }
    return _moneyDetailbtns;
}

@end
