//
//  DRMenuView.m
//  dr
//
//  Created by 毛文豪 on 2017/12/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMenuView.h"

@interface DRMenuView ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIImageView * menuImageView;
@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,assign) BOOL left;
@property (nonatomic,strong) NSMutableArray *buttonArray;

@end

@implementation DRMenuView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray left:(BOOL)left
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleArray = titleArray;
        self.left = left;
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.2);
    
    //添加点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //背景
    CGFloat buttonH = 40;
    CGFloat menuImageViewW = 95;
    CGFloat menuImageViewH = 7 + buttonH * self.titleArray.count;
    UIImage *menuImage;
    CGFloat menuImageViewX;
    if (self.left) {
        menuImageViewX = 5;
        menuImage = [[UIImage imageNamed:@"left_menu_backview"] stretchableImageWithLeftCapWidth:menuImageViewW / 2 topCapHeight:menuImageViewH / 2];
    }else
    {
        menuImageViewX = screenWidth - 5 - menuImageViewW;
        menuImage = [[UIImage imageNamed:@"right_menu_backview"] stretchableImageWithLeftCapWidth:menuImageViewW / 2 topCapHeight:menuImageViewH / 2];
    }
    UIImageView * menuImageView = [[UIImageView alloc] initWithImage:menuImage];
    self.menuImageView = menuImageView;
    menuImageView.frame = CGRectMake(menuImageViewX, statusBarH + 16 + 24, menuImageViewW, menuImageViewH);
    [self addSubview:menuImageView];
    
    //菜单按钮
    CGFloat buttonW = menuImageView.width;
    CGFloat padding = 7;
    for (int i = 0; i < self.titleArray.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(menuImageView.x, menuImageView.y + padding + buttonH * i, buttonW, buttonH);
        [button setTitle:self.titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttonArray addObject:button];
        
        //分割线
        if (i != self.titleArray.count - 1) {
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(2, button.height - 1, button.width - 4, 1)];
            line.backgroundColor = DRColor(50, 50, 50, 1);
            [button addSubview:line];
        }
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.menuImageView.superview];
        if (CGRectContainsPoint(self.menuImageView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}

- (void)buttonDidClick:(UIButton *)button
{
    [self removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(menuViewButtonDidClick:)]) {
        [_delegate menuViewButtonDidClick:button];
    }
}
- (void)setMenuViewX:(CGFloat)menuViewX
{
    _menuViewX = menuViewX;
    
    self.menuImageView.x = _menuViewX;
    for (UIButton * button in self.buttonArray) {
        button.x = _menuViewX;
    }
}
- (NSMutableArray *)buttonArray
{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

@end
