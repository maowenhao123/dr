//
//  DRPraiseListViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/13.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseListViewController.h"
#import "DRPraiseRealTimeListViewController.h"
#import "DRPraiseWinnerListViewController.h"
#import "DRPraiseMyAwardViewController.h"

@interface DRPraiseListViewController ()

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) UIButton * selectedButton;
@property (nonatomic, weak) UIView * bottomView;

@end

@implementation DRPraiseListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
}

- (void)setupChilds
{
    CGFloat bottomViewH = 45 + [DRTool getSafeAreaBottom];
    CGFloat viewControllerH = screenHeight - statusBarH - navBarH - bottomViewH;
    //实时榜单
    DRPraiseRealTimeListViewController * realTimeListVC = [[DRPraiseRealTimeListViewController alloc] init];
    realTimeListVC.currentIndex = (int)self.realTimeIndex;
    realTimeListVC.view.frame = CGRectMake(0, 0, screenWidth, viewControllerH);
    [self addChildViewController:realTimeListVC];

    //获奖名单
    DRPraiseWinnerListViewController * winnerListVC = [[DRPraiseWinnerListViewController alloc] init];
    winnerListVC.view.frame = CGRectMake(0, 0, screenWidth, viewControllerH);
    [self addChildViewController:winnerListVC];

    //获奖名单
    DRPraiseMyAwardViewController * myAwardVC = [[DRPraiseMyAwardViewController alloc] init];
    myAwardVC.view.frame = CGRectMake(0, 0, screenWidth, viewControllerH);
    [self addChildViewController:myAwardVC];

    if (self.index == 0) {
        realTimeListVC.view.height += statusBarH + navBarH;
        [self.view addSubview:realTimeListVC.view];
        self.currentViewController = realTimeListVC;
    }else if (self.index == 1)
    {
        winnerListVC.view.height += statusBarH + navBarH;
        [self.view addSubview:winnerListVC.view];
        self.currentViewController = winnerListVC;
    }else if (self.index == 2)
    {
        myAwardVC.view.height += statusBarH + navBarH;
        [self.view addSubview:myAwardVC.view];
        self.currentViewController = myAwardVC;
    }
    
    //底部按钮
    CGFloat bottomViewY = screenHeight - statusBarH - navBarH - bottomViewH;
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY, screenWidth, bottomViewH)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    lineView.backgroundColor = DRGrayLineColor;
    [bottomView addSubview:lineView];
    
    NSArray * titleButtons = @[@"实时榜单", @"获奖名单", @"我的奖励"];
    for (int i = 0; i < titleButtons.count; i++) {
        UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomButton.tag = i;
        [bottomButton setTitle:titleButtons[i] forState:UIControlStateNormal];
        [bottomButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        [bottomButton setTitleColor:DRDefaultColor forState:UIControlStateSelected];
        bottomButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(31)];
        if (i == self.index) {
            bottomButton.selected = YES;
            bottomButton.userInteractionEnabled = NO;
            self.selectedButton = bottomButton;
        }
        bottomButton.frame = CGRectMake(screenWidth / titleButtons.count * i, 1, screenWidth / titleButtons.count, 44);
        [bottomButton addTarget:self action:@selector(bottomButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:bottomButton];
    }
    self.title = titleButtons[self.index];
}

- (void)bottomButtonDidClick:(UIButton *)button
{
    self.selectedButton.selected = NO;
    self.selectedButton.userInteractionEnabled = YES;
    button.selected = YES;
    button.userInteractionEnabled = NO;
    self.selectedButton = button;
    self.title = self.selectedButton.currentTitle;

    //转场
    UIViewController * newController = self.childViewControllers[button.tag];
    [self transitionFromViewController:self.currentViewController
                      toViewController:newController
                              duration:DRAnimateDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{

                            }
                            completion:^(BOOL finished) {
                                self.currentViewController = newController;
                            }];
}


@end
