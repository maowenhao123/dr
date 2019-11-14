//
//  DROrderDetailSectionFooterView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/13.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DROrderDetailSectionFooterView.h"

@interface DROrderDetailSectionFooterView ()

@property (nonatomic,weak) UILabel * goodMoneyLabel;
@property (nonatomic,weak) UILabel * mailmentLabel;

@end

@implementation DROrderDetailSectionFooterView

+ (DROrderDetailSectionFooterView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderDetailSectionFooterViewId";
    DROrderDetailSectionFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DROrderDetailSectionFooterView alloc] initWithReuseIdentifier:ID];
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
    //footerView
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 35 * 2)];
    footerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:footerView];
    
    //商品金额
    UIView * goodMoneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 35)];
    goodMoneyView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:goodMoneyView];
    
    UIView * goodMoneyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    goodMoneyLine.backgroundColor = DRWhiteLineColor;
    [goodMoneyView addSubview:goodMoneyLine];
    
    UILabel * goodMoneyTitleLabel = [[UILabel alloc] init];
    goodMoneyTitleLabel.text = @"商品金额";
    goodMoneyTitleLabel.textColor = DRBlackTextColor;
    goodMoneyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize goodMoneyTitleLabelSize = [goodMoneyTitleLabel.text sizeWithLabelFont:goodMoneyTitleLabel.font];
    goodMoneyTitleLabel.frame = CGRectMake(DRMargin, 0, goodMoneyTitleLabelSize.width, goodMoneyView.height);
    [goodMoneyView addSubview:goodMoneyTitleLabel];
    
    UILabel * goodMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodMoneyTitleLabel.frame) + DRMargin, 0, screenWidth - 2 * DRMargin - CGRectGetMaxX(goodMoneyTitleLabel.frame), goodMoneyView.height)];
    self.goodMoneyLabel = goodMoneyLabel;
    goodMoneyLabel.textColor = DRBlackTextColor;
    goodMoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodMoneyLabel.textAlignment = NSTextAlignmentRight;
    [goodMoneyView addSubview:goodMoneyLabel];
    
    //运费
    UIView * mailmentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(goodMoneyView.frame), screenWidth, 35)];
    mailmentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:mailmentView];
    
    UIView * mailmentLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    mailmentLine.backgroundColor = DRWhiteLineColor;
    [mailmentView addSubview:mailmentLine];
    
    UILabel * mailmentTitleLabel = [[UILabel alloc] init];
    mailmentTitleLabel.text = @"运费";
    mailmentTitleLabel.textColor = DRBlackTextColor;
    mailmentTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize mailmentTitleLabelSize = [mailmentTitleLabel.text sizeWithLabelFont:mailmentTitleLabel.font];
    mailmentTitleLabel.frame = CGRectMake(DRMargin, 0, mailmentTitleLabelSize.width, mailmentView.height);
    [mailmentView addSubview:mailmentTitleLabel];
    
    UILabel * mailmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mailmentTitleLabel.frame) + DRMargin, 0, screenWidth - 2 * DRMargin - CGRectGetMaxX(mailmentTitleLabel.frame), mailmentView.height)];
    self.mailmentLabel = mailmentLabel;
    mailmentLabel.textColor = DRBlackTextColor;
    mailmentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    mailmentLabel.textAlignment = NSTextAlignmentRight;
    [mailmentView addSubview:mailmentLabel];
    
}

- (void)setStoreOrderModel:(DRStoreOrderModel *)storeOrderModel
{
    _storeOrderModel = storeOrderModel;
    
    NSInteger goodCount = 0;
    for (DROrderItemDetailModel *orderItemDetailModel in _storeOrderModel.detail) {
        goodCount += [orderItemDetailModel.purchaseCount integerValue];
    }
    self.goodMoneyLabel.text = [NSString stringWithFormat:@"%ld件商品，共￥%@", (long)goodCount, [DRTool formatFloat:[_storeOrderModel.priceCount doubleValue] / 100]];
    
    NSArray * mailTypes = @[@"混合", @"包邮", @"肉币支付", @"快递到付"];
    int mailType = [_storeOrderModel.mailType intValue];
    if (mailType < mailTypes.count) {
        self.mailmentLabel.text = mailTypes[mailType];
    }else
    {
        self.mailmentLabel.text = @"未知";
    }
}

@end
