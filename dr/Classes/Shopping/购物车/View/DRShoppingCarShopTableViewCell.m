//
//  DRShoppingCarShopTableViewCell.m
//  dr
//
//  Created by apple on 2017/3/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShoppingCarShopTableViewCell.h"
#import "DRShoppingCarCache.h"

@interface DRShoppingCarShopTableViewCell ()

@property (nonatomic, weak) UIButton * selectedButton;//选择按钮
@property (nonatomic, weak) UIImageView * logoImageView;//logo
@property (nonatomic, weak) UILabel * shopNameLabel;//店铺名称

@end

@implementation DRShoppingCarShopTableViewCell

+ (DRShoppingCarShopTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShoppingCarShopTableViewCell";
    DRShoppingCarShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShoppingCarShopTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = DRBackgroundColor;
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
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 40)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    //选择按钮
    CGFloat selectedButtonWH = 20;
    UIButton * selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectedButton = selectedButton;
    selectedButton.frame = CGRectMake(0, 0, DRMargin + selectedButtonWH + 10, contentView.height);
    [selectedButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [selectedButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [selectedButton addTarget:self action:@selector(selectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:selectedButton];
    
    //店铺logo
    CGFloat logoImageViewWH = 21;
    CGFloat logoImageViewY = (contentView.height - logoImageViewWH) / 2;
    UIImageView * logoImageView = [[UIImageView alloc] init];
    self.logoImageView = logoImageView;
    logoImageView.frame = CGRectMake(CGRectGetMaxX(selectedButton.frame) + 10, logoImageViewY, logoImageViewWH, logoImageViewWH);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.layer.masksToBounds = YES;
    logoImageView.layer.cornerRadius = logoImageView.width / 2;
    [contentView addSubview:logoImageView];
    
    //店铺名称
    UILabel * shopNameLabel = [[UILabel alloc] init];
    self.shopNameLabel = shopNameLabel;
    CGFloat shopNameLabelX = CGRectGetMaxX(logoImageView.frame) + 10;
    shopNameLabel.frame = CGRectMake(shopNameLabelX, 0, contentView.width - shopNameLabelX, contentView.height);
    shopNameLabel.textColor = DRBlackTextColor;
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [contentView addSubview:shopNameLabel];
}

- (void)setModel:(DRShoppingCarShopModel *)model
{
    _model = model;
    //赋值
    self.selectedButton.selected = _model.isSelected;
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_model.shopModel.storeImg];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    self.shopNameLabel.text = _model.shopModel.storeName;
}

- (void)selectedButtonDidClick:(UIButton *)button
{
    BOOL selected = !self.selectedButton.selected;
    [DRShoppingCarCache upDataShopSelectedInShoppingCarWithShopId:self.model.shopModel.id selected:selected];
    if (_delegate && [_delegate respondsToSelector:@selector(upDataShopTableViewCell:isSelected:)]) {
        [_delegate upDataShopTableViewCell:self isSelected:selected];
    }
}

@end
