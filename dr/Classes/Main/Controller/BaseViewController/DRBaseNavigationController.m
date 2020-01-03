//
//  DRBaseNavigationController.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseNavigationController.h"
#import "DRLoadHtmlFileViewController.h"

@interface DRBaseNavigationController ()<UINavigationControllerDelegate>

@end

@implementation DRBaseNavigationController
#pragma mark - 初始化
/**
 *  第一次使用这个类的时候会调用(1个类只会调用1次)
 */
+ (void)initialize
{
    [self setupNavigationBarTheme];
    
    [self setupBarButtonItemTheme];
}

+ (void)setupNavigationBarTheme{
    // 取出appearance对象
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    
    // 设置背景
    [navigationBar setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
    
    //设置颜色
    navigationBar.tintColor = DRBlackTextColor;

    // 设置标题属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = DRBlackTextColor;
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:DRGetFontSize(36)];
    [navigationBar setTitleTextAttributes:textAttrs];
}

+ (void)setupBarButtonItemTheme
{
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = DRBlackTextColor;
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [barButtonItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableDictionary *highlightedTextAttrs = [NSMutableDictionary dictionary];
    highlightedTextAttrs[NSForegroundColorAttributeName] = DRBlackTextColor;
    highlightedTextAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [barButtonItem setTitleTextAttributes:highlightedTextAttrs forState:UIControlStateHighlighted];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

#pragma mark - 跳转下个页面
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(self.tabBarController.viewControllers.count > 0)
    {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [super popViewControllerAnimated:animated];
    
    return vc;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL hiddenNavBar = [viewController isKindOfClass:[NSClassFromString(@"DRHomePageViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRHomePageHtmlViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRGoodDetailViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRShopDetailViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRUserShowViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRMineViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRMyShopViewController") class]] || [viewController isKindOfClass:[NSClassFromString(@"DRHomePageSerachViewController") class]];
    if ([viewController isKindOfClass:[NSClassFromString(@"DRLoadHtmlFileViewController") class]]) {
        DRLoadHtmlFileViewController * loadHtmlFileVC = (DRLoadHtmlFileViewController *)viewController;
        if (loadHtmlFileVC.hiddenNav) {
            hiddenNavBar = YES;
        }
    }
    [navigationController setNavigationBarHidden:hiddenNavBar animated:YES];
}

@end
