//
//  DRPraiseChooseAwardView.m
//  dr
//
//  Created by 毛文豪 on 2018/12/24.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseChooseAwardView.h"
#import "DRPraiseListViewController.h"

@interface DRPraiseChooseAwardView ()<UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIImageView * backView;

@end

@implementation DRPraiseChooseAwardView

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
    
    //添加点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //背景
    CGFloat backViewW = 300;
    CGFloat backViewH = 250;
    UIImageView * backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewW, backViewH)];
    self.backView = backView;
    backView.center = CGPointMake(screenWidth / 2, (screenHeight - [DRTool getSafeAreaBottom]) / 2);
    backView.image = [UIImage resizedImageWithName:@"praise_choose_award_back" left:0 top:0.5];
    backView.userInteractionEnabled = YES;
    [self addSubview:backView];
    
    //提示
    UILabel * contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 0;
    NSMutableAttributedString * contentAttStr = [[NSMutableAttributedString alloc]initWithString:@"您在周榜中名列前茅，赠送您50元红包组或多肉一盆。"];
    [contentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(32)] range:NSMakeRange(0, contentAttStr.length)];
    [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, contentAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [contentAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentAttStr.length)];
    contentLabel.attributedText = contentAttStr;
    CGSize contentSize = [contentLabel.attributedText boundingRectWithSize:CGSizeMake(backView.width - 20 * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    contentLabel.frame = CGRectMake(20, 115, contentSize.width, contentSize.height);
    [backView addSubview:contentLabel];
    
    //领取奖励
    CGFloat awardButtonW = 217;
    CGFloat awardButtonH = 45;
    CGFloat awardButtonX = (backView.width - awardButtonW) / 2;
    UIButton * awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    awardButton.frame = CGRectMake(awardButtonX, CGRectGetMaxY(contentLabel.frame) + 20, awardButtonW, awardButtonH);
    [awardButton setBackgroundImage:[UIImage imageNamed:@"button_back_yellow"] forState:UIControlStateNormal];
    [awardButton setTitle:@"领取奖励" forState:UIControlStateNormal];
    [awardButton setTitleColor:DRColor(122, 22, 36, 1) forState:UIControlStateNormal];
    awardButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    [awardButton addTarget:self action:@selector(awardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:awardButton];
}

- (void)tapDidClick
{
    [self removeFromSuperview];
}

- (void)awardButtonDidClick:(UIButton *)button
{
    DRPraiseListViewController * praiseListVC = [[DRPraiseListViewController alloc] init];
    praiseListVC.index = 2;
    [self.ower.navigationController pushViewController:praiseListVC animated:YES];
    
    [self tapDidClick];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.backView.superview];
        if (CGRectContainsPoint(self.backView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}



@end
