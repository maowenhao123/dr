//
//  UITabBar+DRBage.h
//  dr
//
//  Created by 毛文豪 on 2018/8/30.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (DRBage)

- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
