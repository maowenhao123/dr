//
//  UITabBar+DRBage.m
//  dr
//
//  Created by 毛文豪 on 2018/8/30.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "UITabBar+DRBage.h"

#define TabbarItemNums 5.0

@implementation UITabBar (DRBadge)

//显示小红点
- (void)showBadgeOnItemIndex:(int)index
{
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 4.5;//圆形
    badgeView.backgroundColor = [UIColor redColor];//颜色：红色
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    if (iPhoneX || iPhoneXR || iPhoneXSMax) {
        float percentX = (index + 0.54) / TabbarItemNums;
        CGFloat x = ceilf(percentX * tabFrame.size.width);
        CGFloat y = ceilf(0.10 * tabFrame.size.height);
        badgeView.frame = CGRectMake(x, y, 9, 9);//圆形大小为9
    }else
    {
        float percentX = (index + 0.54) / TabbarItemNums;
        CGFloat x = ceilf(percentX * tabFrame.size.width);
        CGFloat y = ceilf(0.16 * tabFrame.size.height);
        badgeView.frame = CGRectMake(x, y, 9, 9);//圆形大小为9
    }
    [self addSubview:badgeView];
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(int)index
{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(int)index{
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}


@end
