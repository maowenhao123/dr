//
//  DROrderDetailTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/5/23.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderDetailTableViewCell.h"

@interface DROrderDetailTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格

@end

@implementation DROrderDetailTableViewCell

+ (DROrderDetailTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderDetailTableViewCellId";
    DROrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DROrderDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 10, 80, 80)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc]init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
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
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] init];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRBlackTextColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodCountLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:goodPriceLabel];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 99, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

- (void)setDetailModel:(DROrderItemDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    if (DRObjectIsEmpty(_detailModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _detailModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _detailModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.goodSpecificationLabel.text = _detailModel.specification.name;
    }
    self.goodNameLabel.text = _detailModel.goods.name;
    self.goodCountLabel.text = [NSString stringWithFormat:@"数量：%@",_detailModel.purchaseCount];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_detailModel.goods.price doubleValue] / 100]];
    
    //frame
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = self.width - labelX;
    CGFloat labelH = 20;
    if (DRObjectIsEmpty(_detailModel.specification)) {
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
