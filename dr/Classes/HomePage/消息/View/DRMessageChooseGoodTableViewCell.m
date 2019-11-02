//
//  DRMessageChooseGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/12/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMessageChooseGoodTableViewCell.h"

@interface DRMessageChooseGoodTableViewCell ()

@property (nonatomic, weak) UIView *customContentView;
@property (nonatomic, weak) UIButton * selectedButton;//选择按钮
@property (nonatomic, weak) UIView * line;//分割线
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称

@end

@implementation DRMessageChooseGoodTableViewCell

+ (DRMessageChooseGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MessageChooseGoodTableViewCell";
    DRMessageChooseGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRMessageChooseGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    //内容
    UIView *customContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 100)];
    self.customContentView = customContentView;
    customContentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:customContentView];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self.customContentView addSubview:line];
    
    //选择按钮
    CGFloat selectedButtonWH = 20;
    UIButton * selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectedButton = selectedButton;
    selectedButton.frame = CGRectMake(0, 0, DRMargin + selectedButtonWH + 10, customContentView.height);
    [selectedButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [selectedButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [selectedButton addTarget:self action:@selector(selectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:selectedButton];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectedButton.frame) + 10, 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self.customContentView addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    goodNameLabel.numberOfLines = 0;
    [self.customContentView addSubview:goodNameLabel];
     
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self.customContentView addSubview:goodPriceLabel];
}

- (void)setModel:(DRMessageChooseGoodModel *)model
{
    _model = model;
    self.selectedButton.selected = _model.isSelected;
    
    //图片
    NSString * urlStr;
    if (_model.type == 2) {
        urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, _model.group.goods.spreadPics, smallPicUrl];
    }else
    {
        urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, _model.goodModel.spreadPics, smallPicUrl];
    }
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //名称
    NSString * name;
    NSString * description;
    if (_model.type == 2) {
        name = _model.group.goods.name;
        description = _model.group.goods.description_;
    }else
    {
        name = _model.goodModel.name;
        description = _model.goodModel.description_;
    }
    if (DRStringIsEmpty(description)) {
        self.goodNameLabel.text = name;
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", name, description]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(name.length, nameAttStr.length - name.length)];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.string.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + DRMargin;
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - goodNameLabelX - DRMargin, 60) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y, goodNameLabelSize.width, goodNameLabelSize.height);
    }
    
    //价格
    if (_model.type == 2) {//团购
        self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@",[DRTool formatFloat:[_model.group.goods.price doubleValue] / 100]];
    }else
    {
        self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@",[DRTool formatFloat:[_model.goodModel.price doubleValue] / 100]];
    }
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelX = self.goodNameLabel.x;
    CGFloat goodPriceLabelY = CGRectGetMaxY(self.goodImageView.frame) - goodPriceLabelSize.height;
    CGFloat goodPriceLabelW = screenWidth - self.goodNameLabel.x - DRMargin;
    self.goodPriceLabel.frame = CGRectMake(goodPriceLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);
}
//按钮选中
- (void)selectedButtonDidClick:(UIButton *)button
{
    BOOL selected = !self.selectedButton.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(upDataGoodTableViewCell:isSelected:)]) {
        [_delegate upDataGoodTableViewCell:self isSelected:selected];
    }
}

@end
