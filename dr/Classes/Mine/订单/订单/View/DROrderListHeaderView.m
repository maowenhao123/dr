//
//  DROrderListHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DROrderListHeaderView.h"

@interface DROrderListHeaderView ()

@end

@implementation DROrderListHeaderView

+ (DROrderListHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderListHeaderViewId";
    DROrderListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DROrderListHeaderView alloc] initWithReuseIdentifier:ID];
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
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9 + 35)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:headerView];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [headerView addSubview:lineView];
    
    //店铺logo
    CGFloat shopLogoImageViewWH = 21;
    CGFloat shopLogoImageViewY = (35 - shopLogoImageViewWH) / 2 + 9;
    UIImageView * shopLogoImageView = [[UIImageView alloc] init];
    self.shopLogoImageView = shopLogoImageView;
    shopLogoImageView.frame = CGRectMake(DRMargin, shopLogoImageViewY, shopLogoImageViewWH, shopLogoImageViewWH);
    shopLogoImageView.layer.masksToBounds = YES;
    shopLogoImageView.layer.cornerRadius = shopLogoImageView.width / 2;
    [headerView addSubview:shopLogoImageView];
    
    //店铺名称
    UILabel * shopNameLabel = [[UILabel alloc] init];
    self.shopNameLabel = shopNameLabel;
    CGFloat shopNameLabelX = CGRectGetMaxX(shopLogoImageView.frame) + 10;
    shopNameLabel.frame = CGRectMake(shopNameLabelX, 9, screenWidth - shopNameLabelX, 35);
    shopNameLabel.textColor = DRBlackTextColor;
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [headerView addSubview:shopNameLabel];
    
    //状态
    UILabel * statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    statusLabel.textColor = DRDefaultColor;
    [headerView addSubview:statusLabel];
}

- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    if (_orderModel.storeOrders.count == 1) {
        DRStoreOrderModel * storeOrderModel = _orderModel.storeOrders.firstObject;
        NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,storeOrderModel.storeImg];
        [self.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        self.shopNameLabel.text = storeOrderModel.storeName;
    }else
    {
        self.shopLogoImageView.image = [UIImage imageNamed:@"share_logo"];
        self.shopNameLabel.text = @"吾花肉";
    }
    
    int statusInt = [_orderModel.status intValue];
    if (self.isGroup) {
        if (statusInt == 5) {
            self.statusLabel.text = @"拼团中";
        }else if (statusInt == 10 || statusInt == 20 || statusInt == 30)
        {
            self.statusLabel.text = @"拼团成功";
        }else if (statusInt == -5)
        {
            self.statusLabel.text = @"拼团失败";
        }
    }else
    {
        if (statusInt == 30) {
            self.statusLabel.text = @"已完成";
        }else if (statusInt == 0) {
            self.statusLabel.text = @"待付款";
        }else if (statusInt == 5) {
            self.statusLabel.text = @"待成团";
        }else if (statusInt == 10) {
            if ([orderModel.orderType integerValue] == 2) {//团购
                self.statusLabel.text = @"拼团成功，待发货";
            }else{
                self.statusLabel.text = @"待发货";
            }
        }else if (statusInt == 20) {
            self.statusLabel.text = @"待收货";
        }else if (statusInt == -1) {
            self.statusLabel.text = @"已取消";
        }else if (statusInt == -5) {
            self.statusLabel.text = @"拼单失败撤单";
        }else if (statusInt == -6) {
            self.statusLabel.text = @"无货撤单";
        }else if (statusInt == -10 || statusInt == -100) {
            self.statusLabel.text = @"已删除";
        }else if (statusInt == -101)
        {
            self.statusLabel.text = @"已支付";
        }
    }
    CGSize statusLabelSize = [self.statusLabel.text sizeWithLabelFont:self.statusLabel.font];
    self.statusLabel.frame = CGRectMake(screenWidth - DRMargin - statusLabelSize.width, 9, statusLabelSize.width, 35);
}

@end
