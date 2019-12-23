//
//  DRShipmentDetaiMultipleTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentDetaiMultipleTableViewCell.h"
#import "DRDateTool.h"

@interface DRShipmentDetaiMultipleTableViewCell ()

@property (nonatomic,weak) UILabel *timeLabel;
@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UIImageView *grouponImageView;
@property (nonatomic,weak) UIScrollView * goodScrollView;
@property (nonatomic,weak) UILabel * orderDetailLabel;

@end

@implementation DRShipmentDetaiMultipleTableViewCell

+ (DRShipmentDetaiMultipleTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentDetaiMultipleTableViewCellId";
    DRShipmentDetaiMultipleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentDetaiMultipleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //团购
    UIImageView * grouponImageView = [[UIImageView alloc] init];
    self.grouponImageView = grouponImageView;
    grouponImageView.frame = CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 5, 25, 25);
    grouponImageView.image = [UIImage imageNamed:@"groupon_icon"];
    [self addSubview:grouponImageView];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.textColor = DRGrayTextColor;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:timeLabel];
    
    //状态
    UILabel * statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    statusLabel.textColor = DRDefaultColor;
    [self addSubview:statusLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame) + 35, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //scrollview
    UIScrollView * goodScrollView = [[UIScrollView alloc] init];
    self.goodScrollView = goodScrollView;
    [self addSubview:goodScrollView];
    //解决UIScrollView把UITableViewCell的点击事件屏蔽
    self.goodScrollView.userInteractionEnabled = NO;
    [self addGestureRecognizer:self.goodScrollView.panGestureRecognizer];
   
    //角标
    CGFloat accessoryImageViewWH = 15;
    CGFloat accessoryImageViewY =  CGRectGetMaxY(line1.frame) + (100 - accessoryImageViewWH) / 2;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, accessoryImageViewY, accessoryImageViewWH, accessoryImageViewWH)];
    accessoryImageView.image = [UIImage imageNamed:@"big_black_accessory_icon"];
    [self addSubview:accessoryImageView];
    
    //订单视图
    UIView * orderDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 145, screenWidth, 35)];
    orderDetailView.backgroundColor = [UIColor whiteColor];
    [self addSubview:orderDetailView];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [orderDetailView addSubview:line2];
    
    //商品价格
    UILabel * orderDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 35)];
    self.orderDetailLabel = orderDetailLabel;
    orderDetailLabel.textColor = DRBlackTextColor;
    orderDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    orderDetailLabel.textAlignment = NSTextAlignmentRight;
    [orderDetailView addSubview:orderDetailLabel];
}

- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    self.grouponImageView.hidden = YES;
    if ([_orderModel.orderType intValue] == 2) {//团购
        self.grouponImageView.hidden = NO;
    } else {//普通
        self.grouponImageView.hidden = YES;
    }
    
    self.timeLabel.text = [DRDateTool getTimeByTimestamp:_orderModel.createTime format:@"yyyy-MM-dd HH:mm"];
    
    int statusInt = [_orderModel.status intValue];
    if (statusInt == 30) {
        self.statusLabel.text = @"已完成";
    }else if (statusInt == 0) {
        self.statusLabel.text = @"待付款";
    }else if (statusInt == 5) {
        self.statusLabel.text = @"待成团";
    }else if (statusInt == 10) {
        self.statusLabel.text = @"待发货";
    }else if (statusInt == 20) {
        self.statusLabel.text = @"待收货";
    }else if (statusInt == -1) {
        self.statusLabel.text = @"已取消";
    }else if (statusInt == -5) {
        self.statusLabel.text = @"拼单失败撤单";
    }else if (statusInt == -6) {
        self.statusLabel.text = @"无货撤单";
    }
    
    for (UIView * subView in self.goodScrollView.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat padding = 5;
    CGFloat goodImageViewWH = 76;
    for (int i = 0; i < _orderModel.storeOrders.firstObject.detail.count; i++) {
        DROrderItemDetailModel * orderItemDetailModel = _orderModel.storeOrders.firstObject.detail[i];
        UIImageView * goodImageView = [[UIImageView alloc] init];
        goodImageView.frame = CGRectMake((goodImageViewWH + padding) * i, 12, goodImageViewWH, goodImageViewWH);
        goodImageView.contentMode = UIViewContentModeScaleAspectFill;
        goodImageView.layer.masksToBounds = YES;
        if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
            NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.goods.spreadPics, smallPicUrl];
            [goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else
        {
            NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.specification.picUrl, smallPicUrl];
            [goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        [self.goodScrollView addSubview:goodImageView];
    }
    self.goodScrollView.contentSize = CGSizeMake((goodImageViewWH + padding) * _orderModel.storeOrders.firstObject.detail.count, 100);

    NSInteger goodCount = 0;
    for (DRStoreOrderModel * storeOrder in _orderModel.storeOrders) {
        for (DROrderItemDetailModel *orderItemDetailModel in storeOrder.detail) {
            goodCount += [orderItemDetailModel.purchaseCount integerValue];
        }
    }
    self.orderDetailLabel.text = [NSString stringWithFormat:@"共%ld件商品 实付款：￥%@", (long)goodCount, [DRTool formatFloat:[_orderModel.priceCount doubleValue] / 100 + [_orderModel.mailPrice doubleValue] / 100]];
    
    //frame
    CGSize timeLabelSize = [self.timeLabel.text sizeWithLabelFont:self.timeLabel.font];
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.grouponImageView.frame) + 3, 9, timeLabelSize.width, 35);
    if ([_orderModel.orderType intValue] == 2) {//团购
        self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.grouponImageView.frame) + 5, 9, timeLabelSize.width, 35);
    } else//普通
    {
        self.timeLabel.frame = CGRectMake(DRMargin, 9, timeLabelSize.width, 35);
    }
    
    CGSize statusLabelSize = [self.statusLabel.text sizeWithLabelFont:self.statusLabel.font];
    self.statusLabel.frame = CGRectMake(screenWidth - DRMargin - statusLabelSize.width, 9, statusLabelSize.width, 35);

    self.goodScrollView.frame = CGRectMake(DRMargin, 9 + 35, screenWidth - DRMargin - 15, 100);
}


@end
