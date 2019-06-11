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
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 10, 75, 75)];
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
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodPriceLabel];
}

- (void)setDetailModel:(DROrderItemDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_detailModel.goods.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    self.goodNameLabel.text = [NSString stringWithFormat:@"%@", _detailModel.goods.name];
    self.goodCountLabel.text = [NSString stringWithFormat:@"数量：%d",[_detailModel.purchaseCount intValue]];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@",[DRTool formatFloat:[_detailModel.priceCount doubleValue] / [_detailModel.purchaseCount intValue] / 100]];
    
    //frame
    CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    self.goodNameLabel.frame = CGRectMake(goodNameLabelX, 10, goodNameLabelSize.width, goodNameLabelSize.height);
    
    CGSize goodCountLabelSize = [self.goodCountLabel.text sizeWithLabelFont:self.goodCountLabel.font];
    self.goodCountLabel.frame = CGRectMake(goodNameLabelX, 0, goodCountLabelSize.width, goodCountLabelSize.height);
    self.goodCountLabel.centerY = self.goodImageView.centerY;
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelY = 85 - goodPriceLabelSize.height;
    CGFloat goodPriceLabelW = goodPriceLabelSize.width;
    self.goodPriceLabel.frame = CGRectMake(goodNameLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);

}

@end
