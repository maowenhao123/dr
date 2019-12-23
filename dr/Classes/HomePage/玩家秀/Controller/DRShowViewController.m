//
//  DRShowViewController.m
//  dr
//
//  Created by apple on 2017/3/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowViewController.h"
#import "DRAddShowViewController.h"
#import "DRShowTableView.h"
#import "DRShowHeaderView.h"
#import "DRPraiseChooseAwardView.h"
#import "IQKeyboardManager.h"

@interface DRShowViewController ()<AddShowDelegate>

@property (nonatomic, strong) DRShowHeaderView * headerView;
@property (nonatomic, weak) DRShowTableView * showTableView;
@property (nonatomic, weak) DRPraiseChooseAwardView *chooseAwardView;

@end

@implementation DRShowViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = NO;
    keyboardManager.enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enableAutoToolbar = YES;
    keyboardManager.enable = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"玩家秀";
    [self setupChilds];
    [self judgePraiseActivity];
    [self judgePraiseAward];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPraiseActivityEnd) name:@"ShowPraiseActivityEnd1" object:nil];
}

- (void)showPraiseActivityEnd
{
    self.showTableView.tableHeaderView = self.headerView;
}

#pragma mark - 请求数据
- (void)judgePraiseActivity
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G12",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.headerView.openActivity = [json[@"status"] boolValue];
            self.showTableView.tableHeaderView = self.headerView;
        }else
        {
            self.showTableView.tableHeaderView = nil;
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)judgePraiseAward
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G09",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if ([json[@"status"] intValue] == 1) {
                //选择奖励
                DRPraiseChooseAwardView *chooseAwardView = [[DRPraiseChooseAwardView alloc] initWithFrame:KEY_WINDOW.bounds];
                self.chooseAwardView = chooseAwardView;
                chooseAwardView.ower = self;
                [KEY_WINDOW addSubview:chooseAwardView];
            }
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    UIBarButtonItem * addShowBar = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_show_bar"] style:UIBarButtonItemStylePlain target:self action:@selector(addShowBarDidClick)];
    self.navigationItem.rightBarButtonItem = addShowBar;
    
    //tableView
    CGFloat headerViewH = 275 + screenWidth * 150 / 375;
    CGFloat viewH = screenHeight - statusBarH - navBarH;
    DRShowTableView* showTableView = [[DRShowTableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, viewH) style:UITableViewStyleGrouped userId:@"" type:@(1) topY:statusBarH + navBarH];
    self.showTableView = showTableView;
    [self.view addSubview:showTableView];
    [showTableView setupChilds];
    
    //headerView
    self.headerView = [[DRShowHeaderView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, headerViewH)];
    self.headerView.openActivity = NO;
}

- (void)addShowBarDidClick
{
    DRAddShowViewController * addShowVC = [[DRAddShowViewController alloc] init];
    addShowVC.delegate = self;
    [self.navigationController pushViewController:addShowVC animated:YES];
}

- (void)addShowSuccess
{
    [self.showTableView getData];
}

@end
