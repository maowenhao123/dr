//
//  DRMailTemplateListViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRMailTemplateListViewController.h"
#import "DRAddMailTemplateViewController.h"
#import "DRMailTemplateTableViewCell.h"

@interface DRMailTemplateListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UIView *noDataView;
@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation DRMailTemplateListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"运费模版";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addBarDidClick)];
    
    //noDataView
    UIView * noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.noDataView = noDataView;
    noDataView.backgroundColor = DRBackgroundColor;
    noDataView.hidden = YES;
    [self.view addSubview:noDataView];
    
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, screenWidth - 2 * DRMargin, 40);
    addBtn.center = noDataView.center;
    addBtn.backgroundColor = DRDefaultColor;
    [addBtn setTitle:@"创建运费模板" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [addBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = addBtn.height / 2;
    [noDataView addSubview:addBtn];
    
    UILabel * noDataLabel = [[UILabel alloc] init];
    NSMutableAttributedString * noDataAttStr = [[NSMutableAttributedString alloc] initWithString:@"您还没有设置运费模板，快去创建一个吧"];
    [noDataAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, noDataAttStr.length)];
    [noDataAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, noDataAttStr.length)];
    noDataLabel.attributedText = noDataAttStr;
    CGSize noDataLabelSize = [noDataLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    noDataLabel.frame = CGRectMake(0, addBtn.y - 15 - noDataLabelSize.height, screenWidth, noDataLabelSize.height);
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    [noDataView addSubview:noDataLabel];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    //    tableView.hidden = YES;
    [self.view addSubview:tableView];
    
    //footerView
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 29 + 40 + 10)];
    footerView.backgroundColor = DRBackgroundColor;
    
    //确定按钮
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(DRMargin, 29, screenWidth - 2 * DRMargin, 40);
    confirmBtn.backgroundColor = DRDefaultColor;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = confirmBtn.height / 2;
    [footerView addSubview:confirmBtn];
    tableView.tableFooterView = footerView;
}

- (void)addBarDidClick
{
    DRAddMailTemplateViewController * addMailTemplateVC = [[DRAddMailTemplateViewController alloc] init];
    [self.navigationController pushViewController:addMailTemplateVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRMailTemplateTableViewCell *cell = [DRMailTemplateTableViewCell cellWithTableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 9 + 40 + 60 + 35;
}

#pragma mark - 确定按钮点击
- (void)confirmBtnDidClick
{
    
}

#pragma mark - 初始化
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
