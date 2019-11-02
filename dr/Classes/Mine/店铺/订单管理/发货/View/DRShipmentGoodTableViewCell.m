//
//  DRShipmentGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShipmentGoodTableViewCell.h"

@interface DRShipmentGoodTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic,weak) UILabel * goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格

@end

@implementation DRShipmentGoodTableViewCell

+ (DRShipmentGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShipmentGoodTableViewCellId";
    DRShipmentGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShipmentGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin,12, 76, 76)];
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
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodPriceLabel];
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] init];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRBlackTextColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodCountLabel.numberOfLines = 0;
    [self addSubview:goodCountLabel];
}
    
- (void)setOrderItemDetailModel:(DROrderItemDetailModel *)orderItemDetailModel
{
    _orderItemDetailModel = orderItemDetailModel;
    
    //赋值
    if (DRObjectIsEmpty(_orderItemDetailModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _orderItemDetailModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _orderItemDetailModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.goodSpecificationLabel.text = _orderItemDetailModel.specification.name;
    }
    
    CGSize goodNameLabelSize;
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX;
    if (DRStringIsEmpty(_orderItemDetailModel.goods.description_)) {
        self.goodNameLabel.text = _orderItemDetailModel.goods.name;
        goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(labelW, 42)];
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _orderItemDetailModel.goods.name, _orderItemDetailModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _orderItemDetailModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(_orderItemDetailModel.goods.name.length, nameAttStr.length - _orderItemDetailModel.goods.name.length)];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(labelW, 42) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    }

    if ([self.orderType intValue] == 2) {//团购
        self.goodCountLabel.text = [NSString stringWithFormat:@"%@个起团 - 已团%d", self.successCount, [self.payCount intValue]];
    }else
    {
        self.goodCountLabel.text = [NSString stringWithFormat:@"数量：%d", [_orderItemDetailModel.purchaseCount intValue]];
    }
    
    self.goodPriceLabel.text = [NSString stringWithFormat:@"价格：%@元", [DRTool formatFloat:[_orderItemDetailModel.priceCount doubleValue] / 100]];
    
    //frame
    CGFloat labelH = 20;
    if (DRObjectIsEmpty(_orderItemDetailModel.specification)) {
        self.goodNameLabel.frame = CGRectMake(labelX, 12, labelW, labelH);
        self.goodSpecificationLabel.hidden = YES;
        self.goodCountLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 10, labelW, labelH);
        self.goodPriceLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodCountLabel.frame) + 5, labelW, labelH);
    }else
    {
        self.goodNameLabel.frame = CGRectMake(labelX, 12, labelW, labelH);
        self.goodSpecificationLabel.hidden = NO;
        CGSize goodSpecificationLabelSize = [self.goodSpecificationLabel.text sizeWithLabelFont:self.goodSpecificationLabel.font];
        CGFloat goodSpecificationLabelH = goodSpecificationLabelSize.height + 4;
        self.goodSpecificationLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 2, goodSpecificationLabelSize.width + 15, goodSpecificationLabelH);
        self.goodSpecificationLabel.layer.cornerRadius = goodSpecificationLabelH / 2;
        self.goodCountLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodSpecificationLabel.frame) + 3, labelW, goodSpecificationLabelH);
        self.goodPriceLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodCountLabel.frame), labelW, labelH);
    }
}


@end

