//
//  DRSellerLogisticsHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSellerLogisticsHeaderView.h"

@implementation DRSellerLogisticsHeaderView

+ (DRSellerLogisticsHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SellerLogisticsHeaderViewId";
    DRSellerLogisticsHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRSellerLogisticsHeaderView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //headerView
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 40)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:headerView];
    
    //订单跟踪
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = DRBlackTextColor;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    titleLabel.text = @"订单跟踪";
    CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
    titleLabel.frame = CGRectMake(DRMargin, 0, titleLabelSize.width, 40);
    [headerView addSubview:titleLabel];
    
    //    //物流投诉
    //    CGFloat complaintButtonWH = 15;
    //    UIButton * complaintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    complaintButton.frame = CGRectMake(screenWidth - DRMargin - complaintButtonWH, (40 - complaintButtonWH) / 2, complaintButtonWH, complaintButtonWH);
    //    [complaintButton setImage:[UIImage imageNamed:@"logistics_complaint"] forState:UIControlStateNormal];
    //    [complaintButton addTarget:self action:@selector(complaintButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    //    [headerView addSubview:complaintButton];
    //
    //    UILabel * complaintLabel = [[UILabel alloc] init];
    //    complaintLabel.textColor = DRGrayTextColor;
    //    complaintLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    //    complaintLabel.text = @"物流投诉";
    //    CGSize complaintLabelSize = [complaintLabel.text sizeWithLabelFont:complaintLabel.font];
    //    complaintLabel.frame = CGRectMake(complaintButton.x - 2 - complaintLabelSize.width, 0, complaintLabelSize.width, 40);
    //    [headerView addSubview:complaintLabel];
    
    //分割线
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [headerView addSubview:line];
}

@end
