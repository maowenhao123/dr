//
//  DRRewardView.m
//  dr
//
//  Created by dahe on 2019/9/5.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRRewardView.h"
#import "DRLoadHtmlFileViewController.h"

@interface DRRewardView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView * contentView;
@property (nonatomic, copy) NSString * drawUrl;

@end

@implementation DRRewardView

- (instancetype)initWithFrame:(CGRect)frame drawUrl:(NSString *)drawUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        self.drawUrl = drawUrl;
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    //添加点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //内容
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 60 * 2, 150)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.center = self.center;
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 5;
    [self addSubview:contentView];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, contentView.width - 2 * 15, 60)];
    titleLabel.text = @"恭喜您，获得抽奖机会，活动期间，每周都可以活动抽奖机会哦～";
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.numberOfLines = 0;
    [contentView addSubview:titleLabel];
    
    //跳转
    UIButton * jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpBtn.frame = CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 10, contentView.width - 2 * 15, 35);
    jumpBtn.backgroundColor = DRDefaultColor;
    [jumpBtn setTitle:@"去抽奖" forState:UIControlStateNormal];
    [jumpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    jumpBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [jumpBtn addTarget:self action:@selector(jumpBtnClick) forControlEvents:UIControlEventTouchUpInside];
    jumpBtn.layer.masksToBounds = YES;
    jumpBtn.layer.cornerRadius = 3;
    [contentView addSubview:jumpBtn];
    
    //取消按钮
    CGFloat cancelButtonW = 48;
    CGFloat cancelButtonH = 73;
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(contentView.centerX - cancelButtonW / 2, CGRectGetMaxY(contentView.frame), cancelButtonW, cancelButtonH);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"up_grade_cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
}

- (void)closeView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *closeRewardTimeSps_ = [defaults objectForKey:@"closeRewardTimeSps"];
    NSMutableArray * closeRewardTimeSps = [NSMutableArray arrayWithArray:closeRewardTimeSps_];
    if (!closeRewardTimeSps) {
        closeRewardTimeSps = [NSMutableArray array];
    }
    long long currentTimeSp = [[NSDate date] timeIntervalSince1970];
    [closeRewardTimeSps insertObject:@(currentTimeSp) atIndex:0];
    [defaults setObject:closeRewardTimeSps forKey:@"closeRewardTimeSps"];
    [defaults synchronize];
    
    [self removeFromSuperview];
}

- (void)jumpBtnClick
{
    DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:self.drawUrl];
    [self.owerViewController pushViewController:htmlVC animated:YES];
    
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
