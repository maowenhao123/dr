//
//  UIBarButtonItem+DR.h
//  dr
//
//  Created by apple on 17/2/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (DR)

+ (UIBarButtonItem *)itemWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font target:(id)target action:(SEL)action adjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted;
+ (UIBarButtonItem *)itemWithIcon:(NSString *)icon highIcon:(NSString *)highIcon target:(id)target action:(SEL)action;

@end
