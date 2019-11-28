//
//  DRChatOrderTableViewCell.m
//  dr
//
//  Created by dahe on 2019/11/25.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRChatOrderTableViewCell.h"
#import "DRShipmentDetailViewController.h"

@interface DRChatOrderTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic,weak) UILabel * statusLabel;
@property (nonatomic,weak) UIButton *orderButton;

@end

@implementation DRChatOrderTableViewCell

+ (DRChatOrderTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"DRChatOrderTableViewCellId";
    DRChatOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRChatOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 99, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 12, 76, 76)];
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
    
    //状态
    UILabel * statusLabel = [[UILabel alloc] init];
    self.statusLabel = statusLabel;
    statusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    statusLabel.textColor = DRDefaultColor;
    [self addSubview:statusLabel];
    
    //查看订单
    UIButton *orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.orderButton = orderButton;
    [orderButton setTitle:@"订单详情" forState:UIControlStateNormal];
    [orderButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    orderButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [orderButton addTarget:self action:@selector(orderButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    orderButton.layer.masksToBounds = YES;
    orderButton.layer.cornerRadius = 4;
    orderButton.layer.borderColor = DRGrayTextColor.CGColor;
    orderButton.layer.borderWidth = 1;
    [self addSubview:orderButton];
}

- (void)orderButtonDidClick
{
    DRShipmentDetailViewController * shipmentDetailVC = [[DRShipmentDetailViewController alloc] init];
    shipmentDetailVC.orderId = self.orderModel.id;
    [self.viewController.navigationController pushViewController:shipmentDetailVC animated:YES];
}

#pragma mark - 设置数据
- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    //赋值
    DROrderItemDetailModel * orderItemDetailModel = _orderModel.storeOrders.firstObject.detail.firstObject;
    if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
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
    
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX - 70 - DRMargin - 5;
    self.goodNameLabel.text = orderItemDetailModel.goods.name;
    
    CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(labelW, 50)];
    self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y + 5, labelW, goodNameLabelSize.height);
 
    self.statusLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 10, labelW, 20);
    
    self.orderButton.frame = CGRectMake(screenWidth - 70 - DRMargin, 0, 70, 25);
    self.orderButton.centerY = 50;
    
}

@end
