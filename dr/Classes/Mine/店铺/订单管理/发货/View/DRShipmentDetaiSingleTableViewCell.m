//
//  DRShipmentDetaiSingleTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentDetaiSingleTableViewCell.h"
#import "DRDateTool.h"

@interface DRShipmentDetaiSingleTableViewCell ()

@property (nonatomic,weak) UILabel *timeLabel;
@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UIImageView *grouponImageView;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格
@property (nonatomic,weak) UILabel * orderDetailLabel;

@end

@implementation DRShipmentDetaiSingleTableViewCell

+ (DRShipmentDetaiSingleTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentDetaiSingleTableViewCellId";
    DRShipmentDetaiSingleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentDetaiSingleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 9 + 35, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line1.frame) + 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //商品规格
    UILabel * goodSpecificationLabel = [[UILabel alloc] init];
    self.goodSpecificationLabel = goodSpecificationLabel;
    goodSpecificationLabel.backgroundColor = DRWhiteLineColor;
    goodSpecificationLabel.textColor = DRGrayTextColor;
    goodSpecificationLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodSpecificationLabel.textAlignment = NSTextAlignmentCenter;
    goodSpecificationLabel.layer.masksToBounds = YES;
    [self addSubview:goodSpecificationLabel];
    
    //角标
    CGFloat accessoryImageViewWH = 15;
    UIImageView * accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - accessoryImageViewWH, 0, accessoryImageViewWH, accessoryImageViewWH)];
    accessoryImageView.centerY = goodImageView.centerY;
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
    
    DROrderItemDetailModel * orderItemDetailModel = _orderModel.storeOrders.firstObject.detail.firstObject;
    if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX - 20;
    if (DRStringIsEmpty(orderItemDetailModel.goods.description_)) {
        self.goodNameLabel.text = orderItemDetailModel.goods.name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(labelW, 40)];
        self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y + 5, labelW, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", orderItemDetailModel.goods.name, orderItemDetailModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, orderItemDetailModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( orderItemDetailModel.goods.name.length, nameAttStr.length - orderItemDetailModel.goods.name.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(labelW, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y + 5, labelW, goodNameLabelSize.height);
    }
    
    if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
        self.goodSpecificationLabel.hidden = YES;
    }else
    {
        self.goodSpecificationLabel.hidden = NO;
        self.goodSpecificationLabel.text = orderItemDetailModel.specification.name;
        CGSize goodSpecificationLabelSize = [self.goodSpecificationLabel.text sizeWithLabelFont:self.goodSpecificationLabel.font];
        CGFloat goodSpecificationLabelH = goodSpecificationLabelSize.height + 4;
        self.goodSpecificationLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 10, goodSpecificationLabelSize.width + 15, goodSpecificationLabelH);
        self.goodSpecificationLabel.layer.cornerRadius = goodSpecificationLabelH / 2;
    }
    
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
    } else {//普通
        self.timeLabel.frame = CGRectMake(DRMargin, 9, timeLabelSize.width, 35);
    }
    
    CGSize statusLabelSize = [self.statusLabel.text sizeWithLabelFont:self.statusLabel.font];
    self.statusLabel.frame = CGRectMake(screenWidth - DRMargin - statusLabelSize.width, 9, statusLabelSize.width, 35);
}


@end
