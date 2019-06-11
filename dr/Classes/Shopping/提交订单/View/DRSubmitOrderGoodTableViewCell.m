//
//  DRSubmitOrderGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/3/27.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSubmitOrderGoodTableViewCell.h"

@interface DRSubmitOrderGoodTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格

@end

@implementation DRSubmitOrderGoodTableViewCell

+ (DRSubmitOrderGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SubmitOrderGoodTableViewCellId";
    DRSubmitOrderGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSubmitOrderGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];
    
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

- (void)setModel:(DROrderItemDetailModel *)model
{
    _model = model;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_model.goods.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.goodNameLabel.text = _model.goods.name;
    self.goodCountLabel.text = [NSString stringWithFormat:@"数量：%@",_model.purchaseCount];
    if ([DRTool showDiscountPriceWithGoodModel:_model.goods]) {
        NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goods.discountPrice doubleValue] / 100]];
        NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goods.price doubleValue] / 100]];
        NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
        NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
        [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(0, newPriceStr.length)];
        [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
        [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(0, newPriceStr.length)];
        [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
        [priceAttStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
        self.goodPriceLabel.attributedText = priceAttStr;
    }else
    {
        self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goods.price doubleValue] / 100]];
    }
    
    //frame
    CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    self.goodNameLabel.frame = CGRectMake(goodNameLabelX, 10, goodNameLabelSize.width, goodNameLabelSize.height);
    
    CGSize goodCountLabelSize = [self.goodCountLabel.text sizeWithLabelFont:self.goodCountLabel.font];
    self.goodCountLabel.frame = CGRectMake(goodNameLabelX, 0, goodCountLabelSize.width, goodCountLabelSize.height);
    self.goodCountLabel.centerY = self.goodImageView.centerY;
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelY = 90 - goodPriceLabelSize.height;
    CGFloat goodPriceLabelW = goodPriceLabelSize.width;
    self.goodPriceLabel.frame = CGRectMake(goodNameLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);
    
}


@end
