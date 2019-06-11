//
//  UIViewController+DRNoNetController.h
//  dr
//
//  Created by 毛文豪 on 2017/5/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRNoNetView.h"

@interface UIViewController (DRNoNetController) <DRNoNetViewDelegate>

/**
 *  为控制器扩展方法，刷新网络时候执行，建议必须实现
 */
- (void)getData;

/**
 *  显示没有网络
 */
- (void)showNonetWork;

/**
 *  隐藏没有网络
 */
- (void)hiddenNonetWork;

@end
