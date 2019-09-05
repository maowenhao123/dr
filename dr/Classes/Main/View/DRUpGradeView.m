//
//  DRUpGradeView.m
//  dr
//
//  Created by 毛文豪 on 2017/10/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRUpGradeView.h"

@interface DRUpGradeView ()<UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIImageView * backView;
@property (nonatomic,strong) DRUpgradeModel * upgradeModel;

@end

@implementation DRUpGradeView

- (instancetype)initWithFrame:(CGRect)frame upgradeModel:(DRUpgradeModel *)upgradeModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.upgradeModel = upgradeModel;
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
    CGFloat backViewW = 287;
    CGFloat backViewH = 300;
    UIImageView * backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backViewW, backViewH)];
    self.backView = backView;
    backView.center = self.center;
    backView.image = [UIImage imageNamed:@"up_grade_back"];
    backView.userInteractionEnabled = YES;
    [self addSubview:backView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.text = [NSString stringWithFormat:@"%@新版本更新内容", self.upgradeModel.version];
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
    titleLabel.frame = CGRectMake(0, 95, backView.width, titleLabelSize.height);
    [backView addSubview:titleLabel];
    
    //内容
    UIScrollView * contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 10, backView.width, backView.height - CGRectGetMaxY(titleLabel.frame) - 10 - 37 - 2 * 7)];
    [backView addSubview:contentScrollView];
    
    UILabel * contentLabel = [[UILabel alloc]init];
    contentLabel.numberOfLines = 0;
    NSString * contentStr = self.upgradeModel.description_;
    if (!DRStringIsEmpty(contentStr)) {
        NSMutableAttributedString * contentAttStr = [[NSMutableAttributedString alloc]initWithString:contentStr];
        [contentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, contentAttStr.length)];
        [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRColor(148, 148, 148, 1) range:NSMakeRange(0, contentAttStr.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;
        [contentAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentAttStr.length)];
        contentLabel.attributedText = contentAttStr;
        CGSize contentSize = [contentLabel.attributedText boundingRectWithSize:CGSizeMake(backView.width - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        contentLabel.frame = CGRectMake(DRMargin, 0, contentSize.width, contentSize.height);
        [contentScrollView addSubview:contentLabel];
        contentScrollView.contentSize = CGSizeMake(contentScrollView.contentSize.width, CGRectGetMaxY(contentLabel.frame));
    }
    
    //更新按钮
    CGFloat buttonW = 233;
    CGFloat buttonH = 37;
    CGFloat buttonX = (backView.width - buttonW) / 2;
    CGFloat buttonY = backView.height - buttonH - 7;
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"up_grade_confirm_btn_icon"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:confirmBtn];
    
    //取消按钮
    CGFloat cancelButtonW = 48;
    CGFloat cancelButtonH = 73;
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(backView.centerX - cancelButtonW / 2, CGRectGetMaxY(backView.frame), cancelButtonW, cancelButtonH);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"up_grade_cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    //动画
    backView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         backView.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

- (void)tapDidClick
{
    [self removeFromSuperview];
}

- (void)confirmBtnClick
{
    [self removeFromSuperview];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.upgradeModel.url]];
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
