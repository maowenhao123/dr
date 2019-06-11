//
//  DRShopNewsView.m
//  dr
//
//  Created by 毛文豪 on 2018/4/26.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRShopNewsView.h"
#import "DRMailSettingViewController.h"
#import "UIButton+DR.h"

@interface DRShopNewsView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView * contentView;

@end

@implementation DRShopNewsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 2 * 35, 0)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, contentView.width, 35)];
    titleLabel.text = @"重要提醒";
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleLabel];
    
    //标题
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 0;
    DRUser *user = [DRUserDefaultTool user];
    NSMutableAttributedString *contentAttStr = [[NSMutableAttributedString alloc] initWithString:@"1、已上架商品不再默认开启团购，如需开启请在‘宝贝管理’中编辑\n2、商品运费改为在‘运费管理’中统一设置\n3、发布新商品前必须首先设置运费\n4、运费由买家支付到本平台，买家确认收货后全额结算到卖家账户\n5、未设置运费的前提下，已上架商品将沿用原有运费方式（到付或包邮），建议您尽快设置"];
    [contentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, contentAttStr.length)];
    [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, contentAttStr.length)];
    [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRViceColor range:[contentAttStr.string rangeOfString:user.phone]];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;//行间距
    [contentAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentAttStr.length)];
    contentLabel.attributedText = contentAttStr;
    CGSize contentLabelSize = [contentLabel.attributedText boundingRectWithSize:CGSizeMake(contentView.width - 2 * 15, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    contentLabel.frame = CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 10, contentLabelSize.width, contentLabelSize.height);
    [contentView addSubview:contentLabel];
    
    //不再提示
    UIButton * noPromptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    noPromptButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentLabel.frame) + 10, 100, 35);
    [noPromptButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [noPromptButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [noPromptButton setTitle:@"不再提示" forState:UIControlStateNormal];
    [noPromptButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    noPromptButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [noPromptButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    [noPromptButton addTarget:self action:@selector(noPromptButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:noPromptButton];
    
    //分割线
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(noPromptButton.frame) + 10, contentView.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    CGFloat buttonH = 45;
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(contentView.width / 2 - 0.5, CGRectGetMaxY(line1.frame), 1, buttonH)];
    line2.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line2];
    
    //按钮
    CGFloat buttonW = contentView.width / 2;
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonW * i, CGRectGetMaxY(line1.frame), buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"知道了" forState:UIControlStateNormal];
            [button setTitleColor:DRColor(148, 148, 148, 1) forState:UIControlStateNormal];
        }else
        {
            [button setTitle:@"设置运费" forState:UIControlStateNormal];
            [button setTitleColor:DRRedTextColor forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
    }
    
    contentView.height = CGRectGetMaxY(line1.frame) + buttonH;
    contentView.center = self.center;
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 7;
    
    contentView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         contentView.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

- (void)noPromptButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    [DRUserDefaultTool saveInt:button.selected forKey:@"noPromptShopNews"];
}

- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 1) {
        self.block();
    }
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.contentView.superview];
        if (CGRectContainsPoint(self.contentView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}

@end
