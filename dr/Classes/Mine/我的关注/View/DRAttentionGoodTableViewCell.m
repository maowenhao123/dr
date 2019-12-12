//
//  DRAttentionGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/4/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAttentionGoodTableViewCell.h"

@interface DRAttentionGoodTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格

@end

@implementation DRAttentionGoodTableViewCell

+ (DRAttentionGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"AttentionGoodTableViewCellId";
    DRAttentionGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRAttentionGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 8, 88, 88)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    CGSize goodPriceLabelSize = [goodPriceLabel.text sizeWithLabelFont:goodPriceLabel.font];
    CGFloat goodPriceLabelX = self.goodNameLabel.x;
    CGFloat goodPriceLabelY = CGRectGetMaxY(goodImageView.frame) - goodPriceLabelSize.height;
    CGFloat goodPriceLabelW = screenWidth - self.goodNameLabel.x - DRMargin;
    goodPriceLabel.frame = CGRectMake(goodPriceLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);
    [self addSubview:goodPriceLabel];
}

- (void)setJson:(id)json
{
    _json = json;
    NSDictionary * dic = _json[@"goods"];
    //logo
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,dic[@"spreadPics"],smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    NSString * name = dic[@"name"];
    NSString * description = dic[@"description"];
    if (DRStringIsEmpty(description)) {
        self.goodNameLabel.text = name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 5, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", name, description]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(name.length, nameAttStr.length - name.length)];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.string.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + DRMargin;
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - goodNameLabelX - DRMargin, 60) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 5, goodNameLabelSize.width, goodNameLabelSize.height);
    }

    //价格
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[dic[@"price"] doubleValue] / 100]];
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelX = self.goodNameLabel.x;
    CGFloat goodPriceLabelY = CGRectGetMaxY(self.goodImageView.frame) - goodPriceLabelSize.height - 5;
    CGFloat goodPriceLabelW = screenWidth - self.goodNameLabel.x - DRMargin;
    self.goodPriceLabel.frame = CGRectMake(goodPriceLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);

}


@end
