//
//  DRShoppingTableViewCell.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShoppingCarTableViewCell.h"
#import "DRAdjustNumberView.h"

@interface DRShoppingCarTableViewCell ()<DRAdjustNumberViewDelegate>

@property (nonatomic, weak) UIView *customContentView;
@property (nonatomic, weak) UIButton * selectedButton;//选择按钮
@property (nonatomic, weak) UIView * line;//分割线
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格

@end

@implementation DRShoppingCarTableViewCell

+ (DRShoppingCarTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShoppingCarTableViewCell";
    DRShoppingCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShoppingCarTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    [self.customContentView addSubview:goodNameLabel];
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] init];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRBlackTextColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self.customContentView addSubview:goodCountLabel];

    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self.customContentView addSubview:goodPriceLabel];
    
    //改变数量
    DRAdjustNumberView * numberView = [[DRAdjustNumberView alloc] init];
    self.numberView = numberView;
    CGFloat numberViewW = 90;
    CGFloat numberViewH = 27;
    CGFloat numberViewX = customContentView.width - DRMargin - numberViewW;
    CGFloat numberViewY = customContentView.height - 12 - numberViewH;
    numberView.frame = CGRectMake(numberViewX, numberViewY, numberViewW, numberViewH);
    numberView.delegate = self;
    numberView.textField.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self.customContentView addSubview:numberView];
}
- (void)setEdit:(BOOL)edit
{
    _edit = edit;
    if (_edit) {//编辑状态
        self.numberView.hidden = NO;
    }else
    {
        self.numberView.hidden = YES;
    }
}

- (void)setModel:(DRShoppingCarGoodModel *)model
{
    _model = model;
    int minCount = 1;
    if ([_model.goodModel.sellType intValue] == 2) {
        for (NSDictionary * wholesaleRuleDic in _model.goodModel.wholesaleRule) {
            NSInteger index = [_model.goodModel.wholesaleRule indexOfObject:wholesaleRuleDic];
            int count = [wholesaleRuleDic[@"count"] intValue];
            if (index == 0) {
                minCount = count;
            }else
            {
                minCount = count < minCount ? count : minCount;
            }
        }
    }
    self.numberView.min = minCount;
    //plusCount
    if ([DRTool showDiscountPriceWithGoodModel:_model.goodModel]) {
        self.numberView.max =  [_model.goodModel.activityStock intValue];
    }else
    {
        self.numberView.max =  [_model.goodModel.plusCount intValue];
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_model.goodModel.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.selectedButton.selected = _model.isSelected;
    self.goodNameLabel.text = _model.goodModel.name;
    self.goodCountLabel.text = [NSString stringWithFormat:@"数量：%d",_model.count];
    self.numberView.currentNum = [NSString stringWithFormat:@"%d",_model.count];
    if ([DRTool showDiscountPriceWithGoodModel:_model.goodModel]) {
        NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goodModel.discountPrice doubleValue] / 100]];
        NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goodModel.price doubleValue] / 100]];
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
        self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[_model.goodModel.price doubleValue] / 100]];
    }
    
    //frame
    CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat goodNameLabelW = self.customContentView.width - goodNameLabelX;
    self.goodNameLabel.frame = CGRectMake(goodNameLabelX, 12, goodNameLabelW, goodNameLabelSize.height);
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelX = goodNameLabelX;
    CGFloat goodPriceLabelY = self.customContentView.height - 12 - goodPriceLabelSize.height;
    CGFloat goodPriceLabelW = goodNameLabelW;
    self.goodPriceLabel.frame = CGRectMake(goodPriceLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);
    
    CGSize goodCountLabelSize = [self.goodCountLabel.text sizeWithLabelFont:self.goodCountLabel.font];
    CGFloat goodCountLabelX = goodNameLabelX;
    CGFloat goodCountLabelW = goodNameLabelW;
    self.goodCountLabel.frame = CGRectMake(goodCountLabelX, CGRectGetMaxY(self.goodNameLabel.frame) + 13, goodCountLabelW, goodCountLabelSize.height);
    
}
//按钮选中
- (void)selectedButtonDidClick:(UIButton *)button
{
    BOOL selected = !self.selectedButton.selected;
    [DRUserDefaultTool upDataGoodSelectedInShoppingCarWithGood:self.model.goodModel selected:selected];
    if (_delegate && [_delegate respondsToSelector:@selector(upDataGoodTableViewCell:isSelected:currentNumber:)]) {
        [_delegate upDataGoodTableViewCell:self isSelected:selected currentNumber:self.numberView.currentNum];
    }
}
//数量改变
- (void)adjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number
{
    [DRUserDefaultTool upDataGoodInShoppingCarWithGood:self.model.goodModel count:[number intValue]];
    if (_delegate && [_delegate respondsToSelector:@selector(upDataGoodTableViewCell:isSelected:currentNumber:)]) {
        [_delegate upDataGoodTableViewCell:self isSelected:self.selectedButton.selected currentNumber:self.numberView.currentNum];
    }
}

@end
