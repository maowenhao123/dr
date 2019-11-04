//
//  DRChooseGoodTableViewCell.m
//  dr
//
//  Created by dahe on 2019/11/4.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRChooseGoodTableViewCell.h"

@interface DRChooseGoodTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel * goodPriceLabel;//商品价格
@property (nonatomic, weak) UIButton * chooseButton;

@end

@implementation DRChooseGoodTableViewCell

+ (DRChooseGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ChooseSeckillGoodTableViewCellId";
    DRChooseGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRChooseGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    CGFloat labelX = CGRectGetMaxX(goodImageView.frame) + DRMargin;
    CGFloat labelW = screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + DRMargin);
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, goodImageView.y, labelW, 50)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(goodImageView.frame) - 5 - 20, labelW, 20)];
    self.goodPriceLabel = goodPriceLabel;
    [self addSubview:goodPriceLabel];
    
    //选择
    CGFloat chooseButtonW = 70;
    CGFloat chooseButtonH = 27;
    UIButton * chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseButton.frame = CGRectMake(screenWidth - (chooseButtonW + DRMargin), CGRectGetMaxY(goodImageView.frame) - chooseButtonH, chooseButtonW, chooseButtonH);
    [chooseButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    [chooseButton setTitle:@"选择" forState:UIControlStateNormal];
    chooseButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    chooseButton.layer.masksToBounds = YES;
    chooseButton.layer.cornerRadius = chooseButtonH / 2;
    chooseButton.layer.borderColor = DRDefaultColor.CGColor;
    chooseButton.layer.borderWidth = 1;
    [chooseButton addTarget:self action:@selector(chooseButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:chooseButton];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 99, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

- (void)chooseButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseSeckillGoodTableViewCell:buttonDidClick:)]) {
        [_delegate chooseSeckillGoodTableViewCell:self buttonDidClick:button];
    }
}

- (void)setGoodModel:(DRGoodModel *)goodModel
{
    _goodModel = goodModel;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _goodModel.spreadPics, smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    NSString * goodNameStr = _goodModel.name;
    NSString * goodDesStr = _goodModel.description_;
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", goodNameStr, goodDesStr]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, goodNameStr.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(goodNameStr.length, attStr.length - goodNameStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, goodNameStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(goodNameStr.length, attStr.length - goodNameStr.length)];
    self.goodNameLabel.attributedText = attStr;
    
    NSString * priceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_goodModel.price doubleValue] / 100]];
    NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
    [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(34)] range:NSMakeRange(1, priceAttStr.length - 1)];
    [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, 1)];
    [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, priceAttStr.length)];
    self.goodPriceLabel.attributedText = priceAttStr;
}

@end
