//
//  DRSeckillGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRSeckillGoodTableViewCell.h"

@interface DRSeckillGoodTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *remindLabel;
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel * goodPriceLabel;//商品价格
@property (nonatomic, weak) UIButton * statusButton;

@end

@implementation DRSeckillGoodTableViewCell

+ (DRSeckillGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SeckillGoodTableViewCellId";
    DRSeckillGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSeckillGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, goodImageView.y, labelW - 100, 35)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //活动提示
    UILabel * remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - DRMargin - 100, goodImageView.y, 100, 35)];
    self.remindLabel = remindLabel;
    remindLabel.text = @"正在参加活动";
    remindLabel.textColor = DRDefaultColor;
    remindLabel.textAlignment = NSTextAlignmentRight;
    remindLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:remindLabel];
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(goodNameLabel.frame) + 3, labelW, 20)];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRBlackTextColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodCountLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(goodCountLabel.frame) + 2, labelW, 20)];
    self.goodPriceLabel = goodPriceLabel;
    [self addSubview:goodPriceLabel];
    
    //下架
    UIButton * statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.statusButton = statusButton;
    [statusButton setTitleColor:DRViceColor forState:UIControlStateNormal];
    statusButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    statusButton.layer.masksToBounds = YES;
    statusButton.layer.cornerRadius = 27 / 2;
    statusButton.layer.borderColor = DRViceColor.CGColor;
    statusButton.layer.borderWidth = 1;
    [statusButton addTarget:self action:@selector(statusButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:statusButton];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 99, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

- (void)statusButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(seckillGoodTableViewCell:buttonDidClick:)]) {
        [_delegate seckillGoodTableViewCell:self buttonDidClick:button];
    }
}

- (void)setSeckillGoodModel:(DRSeckillGoodModel *)seckillGoodModel
{
    _seckillGoodModel = seckillGoodModel;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _seckillGoodModel.spreadPics, smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    NSString * goodNameStr = _seckillGoodModel.name;
    NSString * goodDesStr = @"";
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", goodNameStr, goodDesStr]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:[attStr.string rangeOfString:goodNameStr]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:[attStr.string rangeOfString:goodDesStr]];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:[attStr.string rangeOfString:goodNameStr]];
    [attStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:[attStr.string rangeOfString:goodDesStr]];
    self.goodNameLabel.attributedText = attStr;
    
    self.goodCountLabel.text = [NSString stringWithFormat:@"剩余%@", _seckillGoodModel.activityStock];
    
    NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_seckillGoodModel.discountPrice doubleValue] / 100]];
    NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_seckillGoodModel.price doubleValue] / 100]];
    NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
    NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
    [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(34)] range:NSMakeRange(1, newPriceStr.length - 1)];
    [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, 1)];
    [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
    [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, newPriceStr.length)];
    [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
    [priceAttStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
    self.goodPriceLabel.attributedText = priceAttStr;
    
    self.statusButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.statusButton.enabled = NO;
    int status = [_seckillGoodModel.status intValue];
    if (status == 0) {
        [self.statusButton setTitle:@"待审核" forState:UIControlStateNormal];
    }else if (status == 1)
    {
        [self.statusButton setTitle:@"下架" forState:UIControlStateNormal];
        self.statusButton.layer.borderColor = DRViceColor.CGColor;
        self.statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.statusButton.enabled = YES;
    }else if (status == 2)
    {
        [self.statusButton setTitle:@"已驳回" forState:UIControlStateNormal];
    }else if (status == 3)
    {
        [self.statusButton setTitle:@"已下架" forState:UIControlStateNormal];
    }
    self.remindLabel.hidden = status != 1;
    CGSize statusButtonSize = [self.statusButton.currentTitle sizeWithLabelFont:self.statusButton.titleLabel.font];
    CGFloat statusButtonW = statusButtonSize.width + 2 * 20;
    CGFloat statusButtonH = 27;
    self.statusButton.frame = CGRectMake(screenWidth - (statusButtonW + 15), CGRectGetMaxY(self.goodImageView.frame) - statusButtonH, statusButtonW, statusButtonH);
}

@end
