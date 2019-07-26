//
//  DRSettingViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/7/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <HyphenateLite/HyphenateLite.h>
#import "DRSettingViewController.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRTextTableViewCell.h"

@interface DRSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *functionNames;

@end

@implementation DRSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self setupChilds];
}

- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DRBackgroundColor;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //footerView
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 29 + 40 + 10)];
    footerView.backgroundColor = DRBackgroundColor;

    UIButton * exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(20, 29, screenWidth - 2 * 20, 40);
    [exitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [exitButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    exitButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    exitButton.layer.masksToBounds = YES;
    exitButton.layer.cornerRadius = exitButton.height / 2;
    exitButton.layer.borderColor = DRDefaultColor.CGColor;
    exitButton.layer.borderWidth = 1;
    [exitButton addTarget:self action:@selector(exitButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:exitButton];
    tableView.tableFooterView = footerView;
}

- (void)exitButtonDidClick
{
    [MBProgressHUD showMessage:@"正在注销，客官请稍后"];
    
    //异步退出环信
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] logout:YES];
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
            });
        }else
        {
            DRLog(@"退出失败");
        }
    });
    
    //删除用户的个人数据
    [DRUserDefaultTool removeObjectForKey:@"userId"];
    [DRUserDefaultTool removeObjectForKey:@"digest"];
    [DRUserDefaultTool removeUser];
    [DRUserDefaultTool removeShop];
    
    dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(poptime, dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        //退出登录，发送返回首页通知
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            });
        }];
        
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoHomePage" object:nil];
            });
        }];
        [op2 addDependency:op1];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue waitUntilAllOperationsAreFinished];
        [queue addOperation:op1];
        [queue addOperation:op2];
    });
}

#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.functionNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRTextTableViewCell * cell = [DRTextTableViewCell cellWithTableView:tableView];
    cell.functionName = self.functionNames[indexPath.row];
    if (indexPath.row == self.functionNames.count - 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryImageView.hidden = YES;
        //获得当前版本号
        NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
        cell.functionDetail = [NSString stringWithFormat:@"v%@",currentVersion];
        cell.functionDetailLabel.x = screenWidth - DRMargin - cell.functionDetailLabel.width;
    }else
    {
        cell.accessoryImageView.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.functionDetail = nil;
    }
    //分割线
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DRCellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:[NSString stringWithFormat:@"%@/static/about.html", baseUrl]];
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
}

#pragma mark - 初始化
- (NSArray *)functionNames
{
    if (!_functionNames) {
        _functionNames = @[@"关于我们", @"版本号"];
    }
    return _functionNames;
}

@end
