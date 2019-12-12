//
//  DRShipmentGrouponLogisticsAddressTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentGrouponLogisticsAddressTableViewCell.h"

@interface DRShipmentGrouponLogisticsAddressTableViewCell ()

@property (nonatomic, weak) UILabel * mailTitleLabel;
@property (nonatomic, weak) UILabel *countLabel;//数量
@property (nonatomic, weak) UILabel *nameLabel;//名字
@property (nonatomic, weak) UILabel *phoneLabel;//电话
@property (nonatomic, weak) UILabel *addressLabel;//地址
@property (nonatomic, weak) UILabel *logisticsNameLabel;//物流公司
@property (nonatomic, weak) UILabel *logisticsNumLabel;//物流单号
@property (nonatomic, weak) UILabel *mailTypeLabel;//配送方式
@property (nonatomic, weak) UILabel *remarkLabel;//订单备注
@property (nonatomic,weak) UIButton *logisticsButton;
@property (nonatomic,strong) NSMutableArray *titleLabelArray;

@end

@implementation DRShipmentGrouponLogisticsAddressTableViewCell

+ (DRShipmentGrouponLogisticsAddressTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentGrouponLogisticsAddressTableViewCellId";
    DRShipmentGrouponLogisticsAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentGrouponLogisticsAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    CGFloat labelPadding1 = 15;
    CGFloat labelPadding2 = 9;
    CGFloat orderLabelH = (175 - labelPadding1 * 2 - labelPadding2 * 6) / 7;
    CGFloat titleLabelW = 0;
    NSArray * titles = @[@"联系人：", @"联系电话：", @"收货地址：", @"数量：", @"物流公司：", @"物流单号：",@"配送方式：", @"备注："];
    for (NSString *title in titles) {
        CGSize titleLabelSize = [title sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
        titleLabelW = titleLabelW < titleLabelSize.width ? titleLabelSize.width : titleLabelW;
    }
    for (int i = 0; i < titles.count; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, labelPadding1 + (labelPadding2 + orderLabelH) * i, titleLabelW, orderLabelH)];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRGrayTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:titleLabel];
        [self.titleLabelArray addObject:titleLabel];
        if (i == 6) {
            self.mailTitleLabel = titleLabel;
        }
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), labelPadding1 + (labelPadding2 + orderLabelH) * i, screenWidth - DRMargin - CGRectGetMaxX(titleLabel.frame), orderLabelH)];
        if (i == 0) {
            self.countLabel = label;
        }else if (i == 1)
        {
            self.nameLabel = label;
        }else if (i == 2)
        {
            self.phoneLabel = label;
        }else if (i == 3)
        {
            self.addressLabel = label;
        }else if (i == 4)
        {
            self.logisticsNameLabel = label;
        }else if (i == 5)
        {
            self.logisticsNumLabel = label;
        }else if (i == 6)
        {
            self.mailTypeLabel = label;
        }else if (i == 7)
        {
            self.remarkLabel = label;
        }
        label.numberOfLines = 0;
        label.textColor = DRBlackTextColor;
        label.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        [self addSubview:label];
    }
    
    //查看物流
    UIButton *logisticsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.logisticsButton = logisticsButton;
    [logisticsButton setTitle:@"查看物流" forState:UIControlStateNormal];
    [logisticsButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    logisticsButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    [logisticsButton addTarget:self action:@selector(logisticsButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    logisticsButton.layer.masksToBounds = YES;
    logisticsButton.layer.cornerRadius = 4;
    logisticsButton.layer.borderColor = DRGrayTextColor.CGColor;
    logisticsButton.layer.borderWidth = 1;
    [self addSubview:logisticsButton];
}
- (void)logisticsButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(shipmentGrouponLogisticsAddressTableViewCell:logisticsButtonDidClick:)]) {
        [_delegate shipmentGrouponLogisticsAddressTableViewCell:self logisticsButtonDidClick:button];
    }
}
- (void)setDeliveryModel:(DRDeliveryAddressModel *)deliveryModel
{
    _deliveryModel = deliveryModel;
    
    self.countLabel.text = [NSString stringWithFormat:@"%@", _deliveryModel.count];
    self.nameLabel.text = [NSString stringWithFormat:@"%@", _deliveryModel.address.receiverName];
    self.phoneLabel.text = [NSString stringWithFormat:@"%@",_deliveryModel.address.phone];
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@",_deliveryModel.address.province, _deliveryModel.address.city, _deliveryModel.address.address];
    self.logisticsNameLabel.text = [NSString stringWithFormat:@"%@",_deliveryModel.logisticsName];
    self.logisticsNumLabel.text = [NSString stringWithFormat:@"%@",_deliveryModel.logisticsNum];
    
    NSString * mailTypeStr = @"";
    if ([_deliveryModel.freight intValue] > 0) {
        self.mailTitleLabel.text = @"运费：";
        mailTypeStr = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[_deliveryModel.freight doubleValue] / 100]];
    }else if ([_deliveryModel.mailType intValue] == 0 && [_deliveryModel.freight intValue] == 0)
    {
        self.mailTitleLabel.text = @"运费：";
        mailTypeStr = @"包邮";
    }else if ([_deliveryModel.mailType intValue] > 0)
    {
        self.mailTitleLabel.text = @"配送方式：";
        NSArray * mailTypes = @[@"包邮", @"肉币支付", @"快递到付"];
        mailTypeStr = [NSString stringWithFormat:@"%@", mailTypes[[_deliveryModel.mailType intValue] - 1]];
    }
    self.mailTypeLabel.text = mailTypeStr;
    self.remarkLabel.text = _deliveryModel.remarks;
    
    //frame
    CGSize titleLabelSize = [@"收货地址：" sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(24)]];
    CGFloat titleLabelW = titleLabelSize.width;
    
    self.nameLabel.frame = CGRectMake(DRMargin + titleLabelW, DRMargin, _deliveryModel.nameSize.width, _deliveryModel.nameSize.height);
    self.phoneLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.nameLabel.frame) + DRMargin, _deliveryModel.phoneSize.width, _deliveryModel.phoneSize.height);
    self.addressLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.phoneLabel.frame) + DRMargin, _deliveryModel.addressSize.width, _deliveryModel.addressSize.height);
    self.countLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.addressLabel.frame) + DRMargin, _deliveryModel.countSize.width, _deliveryModel.countSize.height);
    self.logisticsNameLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.countLabel.frame) + DRMargin, _deliveryModel.logisticsNameSize.width, _deliveryModel.logisticsNameSize.height);
    self.logisticsNumLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.logisticsNameLabel.frame) + DRMargin, _deliveryModel.logisticsNumSize.width, _deliveryModel.logisticsNumSize.height);
    self.mailTypeLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.logisticsNumLabel.frame) + DRMargin, _deliveryModel.typeSize.width, _deliveryModel.typeSize.height);
    self.remarkLabel.frame = CGRectMake(DRMargin + titleLabelW, CGRectGetMaxY(self.mailTypeLabel.frame) + DRMargin, _deliveryModel.remarkSize.width, _deliveryModel.remarkSize.height);
    
    for (int i = 0; i < self.titleLabelArray.count; i++) {
        UILabel * label = self.titleLabelArray[i];
        if (i == 0) {
            label.frame = CGRectMake(DRMargin, self.nameLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 1)
        {
            label.frame = CGRectMake(DRMargin, self.phoneLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 2)
        {
            label.frame = CGRectMake(DRMargin, self.addressLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 3)
        {
            label.frame = CGRectMake(DRMargin, self.countLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 4)
        {
            label.frame = CGRectMake(DRMargin, self.logisticsNameLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 5)
        {
            label.frame = CGRectMake(DRMargin, self.logisticsNumLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 6)
        {
            label.frame = CGRectMake(DRMargin, self.mailTypeLabel.y, titleLabelW, titleLabelSize.height);
        }else if (i == 7)
        {
            if (DRStringIsEmpty(_deliveryModel.remarks)) {
                label.hidden = YES;
            }else
            {
                label.frame = CGRectMake(DRMargin, self.remarkLabel.y, titleLabelW, titleLabelSize.height);
            }
        }
    }
    
    CGFloat logisticsButtonW = 60;
    CGFloat logisticsButtonH = 20;
    self.logisticsButton.frame = CGRectMake(CGRectGetMaxX(self.logisticsNumLabel.frame) + 9, 0, logisticsButtonW, logisticsButtonH);
    self.logisticsButton.centerY = self.logisticsNumLabel.centerY;
}
#pragma mark - 初始化
- (NSMutableArray *)titleLabelArray
{
    if (!_titleLabelArray) {
        _titleLabelArray = [NSMutableArray array];
    }
    return _titleLabelArray;
}

@end

