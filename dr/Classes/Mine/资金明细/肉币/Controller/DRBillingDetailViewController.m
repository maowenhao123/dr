//
//  DRBillingDetailViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/5/16.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBillingDetailViewController.h"
#import "DRBillingDetailGoodTableViewCell.h"
#import "UITableView+DRNoData.h"

@interface DRBillingDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray *goodArray;

@end

@implementation DRBillingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账单详情";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    CGFloat viewH = screenHeight - statusBarH - navBarH;
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, viewH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 90)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel * incomeLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    incomeLabel.numberOfLines = 0;
    NSString * incomeStr = [NSString stringWithFormat:@"收入\n+%@元", [DRTool formatFloat:[self.moneyDetailmodel.money doubleValue] / 100]];
    NSMutableAttributedString *incomeAttStr = [[NSMutableAttributedString alloc] initWithString:incomeStr];
    [incomeAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, 2)];
    [incomeAttStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(45)] range:NSMakeRange(2, incomeAttStr.length - 2)];
    [incomeAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, incomeAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [incomeAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, incomeAttStr.length)];
    incomeLabel.attributedText = incomeAttStr;
    [headerView addSubview:incomeLabel];
    
    tableView.tableHeaderView = headerView;
    
    //footerView
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 76)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [footerView addSubview:line];
    
    NSArray * titles = @[@"运费：", @"总实收："];
    CGFloat labelH = 18;
    CGFloat labelPadding = 10;
    NSString * freight = [DRTool formatFloat:[self.moneyDetailmodel.detail.freight doubleValue] / 100];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        if (i == 0) {
            titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        }else
        {
            titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        }
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(15, 15 + (labelH + labelPadding) * i, titleLabelSize.width, labelH);
        [footerView addSubview:titleLabel];
        
        UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 15 + (labelH + labelPadding) * i, screenWidth - CGRectGetMaxX(titleLabel.frame) - 15, labelH)];
        contentLabel.textColor = DRBlackTextColor;
        if (i == 0) {
            contentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
            contentLabel.text = [NSString stringWithFormat:@"%@元", freight];
        }else
        {
            double allIncome = [freight doubleValue];
            for (DROrderItemDetailModel *detailModel in self.goodArray) {
                allIncome += [detailModel.goods.agentPrice doubleValue] * [detailModel.purchaseCount intValue] / 100;
            }
            contentLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:allIncome]];
            contentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        }
        contentLabel.textAlignment = NSTextAlignmentRight;
        [footerView addSubview:contentLabel];
    }
    tableView.tableFooterView = footerView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.goodArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRBillingDetailGoodTableViewCell *cell = [DRBillingDetailGoodTableViewCell cellWithTableView:tableView];
    cell.detailModel = self.goodArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}

#pragma mark - 初始化
- (NSMutableArray *)goodArray
{
    if(_goodArray == nil)
    {
        _goodArray = [NSMutableArray array];
        for (DRStoreOrderModel * storeOrders in self.moneyDetailmodel.detail.storeOrders) {
            for (DROrderItemDetailModel * detail in storeOrders.detail) {
                [_goodArray addObject:detail];
            }
        }
    }
    return _goodArray;
}

@end
