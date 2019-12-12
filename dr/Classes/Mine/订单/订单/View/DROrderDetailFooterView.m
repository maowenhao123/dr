//
//  DROrderDetailFooterView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/1.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DROrderDetailFooterView.h"
#import "DRDateTool.h"

@interface DROrderDetailFooterView ()

@property (nonatomic, weak) UILabel *orderNoLabel;//订单编号
@property (nonatomic,weak) UIButton *numberButton;
@property (nonatomic,weak) UIView * orderView;
@property (nonatomic, weak) UILabel *orderTimeLabel;//下单时间
@property (nonatomic, weak) UILabel *orderRemarkLabel;//下单备注
@property (nonatomic,weak) UIView * moneyView;
@property (nonatomic, weak) UILabel *goodMoneyLabel;//商品金额
@property (nonatomic,weak) UIView * redPacketMoneyView;//红包抵用
@property (nonatomic,weak) UILabel * redPacketMoneyLabel;
@property (nonatomic,weak) UIView * mailmentView;//运费
@property (nonatomic, weak) UILabel *mailmentLabel;
@property (nonatomic,weak) UIView * allMoneyView;//总付款
@property (nonatomic, weak) UILabel *allMoneyLabel;

@end

@implementation DROrderDetailFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //分割线
    UIView * lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView1.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView1];
    
    //订单信息
    UIView * orderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView1.frame), screenWidth, 1)];
    self.orderView = orderView;
    orderView.backgroundColor = [UIColor whiteColor];
    [self addSubview:orderView];
    
    CGFloat labelPadding1 = 12;
    CGFloat labelPadding2 = 8;
    CGFloat orderLabelH = [UIFont systemFontOfSize:DRGetFontSize(24)].lineHeight;
    for (int i = 0; i < 3; i++) {
        UILabel * orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, labelPadding1 + (labelPadding2 + orderLabelH) * i, screenWidth - 2 * DRMargin, orderLabelH)];
        if (i == 0) {
            self.orderNoLabel = orderLabel;
            orderLabel.text = @"订单编号：";
        }else if (i == 1)
        {
            self.orderTimeLabel = orderLabel;
            orderLabel.text = @"下单时间：";
        }else if (i == 2)
        {
            self.orderRemarkLabel = orderLabel;
            orderLabel.text = @"备注：";
        }
        orderLabel.textColor = DRGrayTextColor;
        orderLabel.numberOfLines = 0;
        orderLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        [orderView addSubview:orderLabel];
        
        orderView.height = CGRectGetMaxY(orderLabel.frame) + labelPadding1;
    }
    
    UIButton * copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.numberButton = copyButton;
    [copyButton setTitle:@"复制" forState:UIControlStateNormal];
    [copyButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    [copyButton addTarget:self action:@selector(copyButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    copyButton.layer.masksToBounds = YES;
    copyButton.layer.cornerRadius = 3;
    copyButton.layer.borderColor = DRGrayLineColor.CGColor;
    copyButton.layer.borderWidth = 1;
    [orderView addSubview:copyButton];
    
    //金额
    UIView * moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(orderView.frame), screenWidth, 1)];
    self.moneyView = moneyView;
    moneyView.backgroundColor = [UIColor whiteColor];
    [self addSubview:moneyView];
    
    //分割线
    UIView * lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView2.backgroundColor = DRBackgroundColor;
    [moneyView addSubview:lineView2];
    
    UILabel * goodMoneyTitleLabel = [[UILabel alloc] init];
    goodMoneyTitleLabel.text = @"商品金额";
    goodMoneyTitleLabel.textColor = DRBlackTextColor;
    goodMoneyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize goodMoneyTitleLabelSize = [goodMoneyTitleLabel.text sizeWithLabelFont:goodMoneyTitleLabel.font];
    goodMoneyTitleLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(lineView2.frame), goodMoneyTitleLabelSize.width, 35);
    [moneyView addSubview:goodMoneyTitleLabel];
    
    UILabel * goodMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodMoneyTitleLabel.frame) + DRMargin, CGRectGetMaxY(lineView2.frame), screenWidth - 2 * DRMargin - CGRectGetMaxX(goodMoneyTitleLabel.frame), 35)];
    self.goodMoneyLabel = goodMoneyLabel;
    goodMoneyLabel.textColor = DRBlackTextColor;
    goodMoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodMoneyLabel.textAlignment = NSTextAlignmentRight;
    [moneyView addSubview:goodMoneyLabel];
    
    //红包抵用
    UIView * redPacketMoneyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(goodMoneyTitleLabel.frame), screenWidth, 0)];
    self.redPacketMoneyView = redPacketMoneyView;
    redPacketMoneyView.hidden = YES;
    [moneyView addSubview:redPacketMoneyView];
    
    UIView * redPacketMoneyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    redPacketMoneyLine.backgroundColor = DRWhiteLineColor;
    [redPacketMoneyView addSubview:redPacketMoneyLine];
    
    UILabel * redPacketMoneyTitleLabel = [[UILabel alloc] init];
    redPacketMoneyTitleLabel.text = @"红包抵用";
    redPacketMoneyTitleLabel.textColor = DRBlackTextColor;
    redPacketMoneyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize redPacketMoneyTitleLabelSize = [redPacketMoneyTitleLabel.text sizeWithLabelFont:redPacketMoneyTitleLabel.font];
    redPacketMoneyTitleLabel.frame = CGRectMake(DRMargin, 0, redPacketMoneyTitleLabelSize.width, 35);
    [redPacketMoneyView addSubview:redPacketMoneyTitleLabel];
    
    UILabel * redPacketMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(redPacketMoneyTitleLabel.frame) + DRMargin, 0, screenWidth - 2 * DRMargin - CGRectGetMaxX(redPacketMoneyTitleLabel.frame), 35)];
    self.redPacketMoneyLabel = redPacketMoneyLabel;
    redPacketMoneyLabel.textColor = DRRedTextColor;
    redPacketMoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    redPacketMoneyLabel.textAlignment = NSTextAlignmentRight;
    [redPacketMoneyView addSubview:redPacketMoneyLabel];
    
    //运费
    UIView * mailmentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(redPacketMoneyView.frame), screenWidth, 35)];
    self.mailmentView = mailmentView;
    [moneyView addSubview:mailmentView];
    
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
    
    //总金额
    UIView * allMoneyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(mailmentView.frame), screenWidth, 37)];
    self.allMoneyView = allMoneyView;
    [moneyView addSubview:allMoneyView];
    
    UIView * allMoneyLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    allMoneyLine.backgroundColor = DRWhiteLineColor;
    [allMoneyView addSubview:allMoneyLine];
    
    UILabel * allMoneyTitleLabel = [[UILabel alloc] init];
    allMoneyTitleLabel.text = @"实付款";
    allMoneyTitleLabel.textColor = DRBlackTextColor;
    allMoneyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize allMoneyTitleLabelSize = [allMoneyTitleLabel.text sizeWithLabelFont:allMoneyTitleLabel.font];
    allMoneyTitleLabel.frame = CGRectMake(DRMargin, 0, allMoneyTitleLabelSize.width, allMoneyView.height);
    [allMoneyView addSubview:allMoneyTitleLabel];
    
    UILabel * allmoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(allMoneyTitleLabel.frame) + DRMargin, 0, screenWidth - 2 * DRMargin - CGRectGetMaxX(allMoneyTitleLabel.frame), allMoneyView.height)];
    self.allMoneyLabel = allmoneyLabel;
    allmoneyLabel.textColor = DRBlackTextColor;
    allmoneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    allmoneyLabel.textAlignment = NSTextAlignmentRight;
    [allMoneyView addSubview:allmoneyLabel];
    
    moneyView.height = CGRectGetMaxY(allMoneyView.frame);
    self.height = CGRectGetMaxY(moneyView.frame) + 9;
}

- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    self.orderNoLabel.text = [NSString stringWithFormat:@"订单编号：%@", _orderModel.id];
    CGSize orderNoLabelSize = [self.orderNoLabel.text sizeWithLabelFont:self.orderNoLabel.font];
    self.orderNoLabel.width = orderNoLabelSize.width;
    CGFloat copyButtonW = 37;
    CGFloat copyButtonH = 20;
    self.numberButton.frame = CGRectMake(CGRectGetMaxX(self.orderNoLabel.frame) + 5, 0, copyButtonW, copyButtonH);
    self.numberButton.centerY = self.orderNoLabel.centerY;
    self.orderTimeLabel.text = [NSString stringWithFormat:@"下单时间：%@",[DRDateTool getTimeByTimestamp:_orderModel.createTime format:@"yyyy-MM-dd HH:mm:ss"]];
    NSString *remarks = @"";
    DRStoreOrderModel * storeOrder = _orderModel.storeOrders.firstObject;
    if (!DRObjectIsEmpty(storeOrder)) {
        remarks = storeOrder.remarks;
    }
    if (DRStringIsEmpty(remarks)) {
        self.orderRemarkLabel.hidden = YES;
        self.orderView.height = CGRectGetMaxY(self.orderTimeLabel.frame) + 12;
    }else
    {
        self.orderRemarkLabel.hidden = NO;
        self.orderRemarkLabel.text = [NSString stringWithFormat:@"备注：%@", remarks];
        CGSize orderRemarkLabelSize = [self.orderRemarkLabel.text sizeWithFont:self.orderRemarkLabel.font maxSize:CGSizeMake(self.orderRemarkLabel.width, MAXFLOAT)];
        self.orderRemarkLabel.height = orderRemarkLabelSize.height;
        self.orderView.height = CGRectGetMaxY(self.orderRemarkLabel.frame) + 12;
    }
    self.moneyView.y = CGRectGetMaxY(self.orderView.frame);
    
    NSInteger goodCount = 0;
    for (DRStoreOrderModel * storeOrder in _orderModel.storeOrders) {
        for (DROrderItemDetailModel *orderItemDetailModel in storeOrder.detail) {
            goodCount += [orderItemDetailModel.purchaseCount integerValue];
        }
    }
    self.goodMoneyLabel.text = [NSString stringWithFormat:@"%ld件商品，共￥%@", (long)goodCount, [DRTool formatFloat:[orderModel.priceCount doubleValue] / 100]];
    
    double couponPriceF = [_orderModel.couponPrice doubleValue] / 100;
    if (couponPriceF == 0) {
        self.redPacketMoneyView.hidden = YES;
        self.redPacketMoneyView.height = 0;
    }else
    {
        self.redPacketMoneyView.hidden = NO;
        self.redPacketMoneyView.height = 35;
        self.redPacketMoneyLabel.text = [NSString stringWithFormat:@"¥-%@", [DRTool formatFloat:couponPriceF]];
    }
    
    if (_orderModel.storeOrders.count > 1) {//多个店铺
        self.mailmentView.hidden = YES;
        self.mailmentView.height = 0;
        self.mailmentView.y = CGRectGetMaxY(self.redPacketMoneyView.frame);
    }else
    {
        self.mailmentView.hidden = NO;
        self.mailmentView.height = 35;
        self.mailmentView.y = CGRectGetMaxY(self.redPacketMoneyView.frame);
        NSString * mailTypeStr;
        double freight = 0;
        if ([_orderModel.orderType integerValue] == 2) {//团购
            freight = [_orderModel.freight doubleValue] / 100;
        }else
        {
            for (DRStoreOrderModel * storeOrderModel in _orderModel.storeOrders) {
                freight += [storeOrderModel.freight doubleValue] / 100;
            }
        }
        
        if (freight > 0) {
            mailTypeStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:freight]];
        }else if ([_orderModel.mailType intValue] == 0 && freight == 0)
        {
            mailTypeStr = @"包邮";
        }
        else
        {
            NSDictionary *mailTypeDic = @{
                                          @"1":@"包邮",
                                          @"2":@"肉币支付",
                                          @"3":@"快递到付",
                                          };
            mailTypeStr = mailTypeDic[[NSString stringWithFormat:@"%@", _orderModel.mailType]];
        }
        self.mailmentLabel.text = mailTypeStr;
    }

    self.allMoneyView.y = CGRectGetMaxY(self.mailmentView.frame);
    self.allMoneyLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_orderModel.amountPayable doubleValue] / 100]];
    
    self.moneyView.height = CGRectGetMaxY(self.allMoneyView.frame);
    self.height = CGRectGetMaxY(self.moneyView.frame) + 9;
    
}

- (void)copyButtonDidClick
{
    //复制订单号
    if (!DRStringIsEmpty(_orderModel.id)) {
        UIPasteboard *pab = [UIPasteboard generalPasteboard];
        NSString *string = _orderModel.id;
        [pab setString:string];
        [MBProgressHUD showSuccess:@"复制成功"];
    }
}

@end
