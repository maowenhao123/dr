//
//  DRChangeGrouponNumberView.m
//  dr
//
//  Created by 毛文豪 on 2017/11/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeGrouponNumberView.h"

@interface DRChangeGrouponNumberView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView * backView;
@property (nonatomic, weak) UITextField * numberTextField;

@end

@implementation DRChangeGrouponNumberView

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
    CGFloat backViewW = 280;
    CGFloat backViewH = 0;
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backViewW, backViewH)];
    self.backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 5;
    [self addSubview:backView];

    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"修改成团数便于快速结单";
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
    titleLabel.frame = CGRectMake(0, 20, backView.width, titleLabelSize.height);
    [backView addSubview:titleLabel];
    
    //修改成团数
    UITextField * numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLabel.frame) + 15, backView.width - 2 * 15, 35)];
    self.numberTextField = numberTextField;
    numberTextField.backgroundColor = DRColor(242, 242, 242, 1);
    numberTextField.tintColor = DRDefaultColor;
    numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    numberTextField.textAlignment = NSTextAlignmentCenter;
    numberTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    numberTextField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    numberTextField.placeholder = @"请输入修改后的成团数量";
    numberTextField.borderStyle = UITextBorderStyleNone;
    numberTextField.layer.masksToBounds = YES;
    numberTextField.layer.cornerRadius = 3;
    [backView addSubview:numberTextField];
    
    //按钮
    CGFloat buttonW = backView.width / 2;
    CGFloat buttonH = 40;
    CGFloat padding = 20;
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonW * i, CGRectGetMaxY(numberTextField.frame) + padding, buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        }else
        {
            [button setTitle:@"确定" forState:UIControlStateNormal];
            [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
    }
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(numberTextField.frame) + padding, self.backView.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [backView addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(backView.width / 2 - 0.5, CGRectGetMaxY(numberTextField.frame) + padding, 1, buttonH)];
    line2.backgroundColor = DRWhiteLineColor;
    [backView addSubview:line2];
    
    backView.height = CGRectGetMaxY(numberTextField.frame) + padding + buttonH;
    backView.center = self.center;
    //动画
    backView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         backView.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

- (void)buttonDidClick:(UIButton *)button
{
   if (button.tag == 1) {
       if (DRStringIsEmpty(self.numberTextField.text)) {
           [MBProgressHUD showError:@"请输入成团的数量"];
           return;
       }
       
        int number = [self.numberTextField.text intValue];
        if (!(number > 0)) {
            [MBProgressHUD showError:@"请输入正确的成团数量"];
            return;
        }
       
        [self tapDidClick];
        
        if (_delegate && [_delegate respondsToSelector:@selector(changeGrouponNumberView:number:)]) {
            [_delegate changeGrouponNumberView:self number:number];
        }
    }else
    {
        [self tapDidClick];
    }
}

- (void)tapDidClick
{
    [self removeFromSuperview];
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
