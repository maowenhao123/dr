//
//  DRSubmitOrderGoodHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSubmitOrderGoodHeaderView.h"
#import "DRShopDetailViewController.h"

@interface DRSubmitOrderGoodHeaderView ()

@property (nonatomic,weak) UIImageView * shopLogoImageView;
@property (nonatomic,weak) UILabel * shopNameLabel;
@property (nonatomic,weak) UIButton * buyButton;

@end

@implementation DRSubmitOrderGoodHeaderView

+ (DRSubmitOrderGoodHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SubmitOrderGoodHeaderViewId";
    DRSubmitOrderGoodHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRSubmitOrderGoodHeaderView alloc] initWithReuseIdentifier:ID];
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
    shopLogoImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    
//    //凑单
//    UIButton * buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.buyButton = buyButton;
//    [buyButton addTarget:self action:@selector(buyButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:buyButton];
//
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 9 + 34, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [headerView addSubview:line];
}

- (void)buyButtonDidClick
{
    DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
    shopVC.shopId = self.storeOrderModel.storeId;
    [self.viewController.navigationController pushViewController:shopVC animated:YES];
}

- (void)setStoreOrderModel:(DRStoreOrderModel *)storeOrderModel
{
    _storeOrderModel = storeOrderModel;
    
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl, _storeOrderModel.storeImg];
    [self.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    self.shopNameLabel.text = _storeOrderModel.storeName;
    
//    double ruleMoney = [_storeOrderModel.ruleMoney doubleValue] / 100;
//    double priceCount = [_storeOrderModel.priceCount doubleValue] / 100;
//    if (ruleMoney > priceCount) {//不包邮
//        NSMutableAttributedString * buyAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"满%@包邮 去凑单>", [DRTool formatFloat:ruleMoney]]];
//        [buyAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, buyAttStr.length)];
//        [buyAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(0, buyAttStr.length - 4)];
//        [buyAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(buyAttStr.length - 4, 4)];
//        [self.buyButton setAttributedTitle:buyAttStr forState:UIControlStateNormal];
//        CGSize buyButtonSize = [self.buyButton.currentAttributedTitle boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
//        self.buyButton.frame = CGRectMake(screenWidth - 10 - buyButtonSize.width, 9, buyButtonSize.width, 35);
//    }
}

@end
