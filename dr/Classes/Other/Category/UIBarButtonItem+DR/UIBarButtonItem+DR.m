//
//  UIBarButtonItem+DR.m
//  dr
//
//  Created by apple on 17/2/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "UIBarButtonItem+DR.h"

@implementation UIBarButtonItem (DR)

+ (UIBarButtonItem *)itemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font target:(id)target action:(SEL)action adjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
    button.frame = (CGRect){CGPointZero, [text sizeWithLabelFont:font]};
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
+ (UIBarButtonItem *)itemWithIcon:(NSString *)icon highIcon:(NSString *)highIcon target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
    button.frame = (CGRect){CGPointZero, button.currentBackgroundImage.size};
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
