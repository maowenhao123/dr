//
//  DRReturnGoodTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodTableViewCell.h"

@interface DRReturnGoodTableViewCell ()

@property (nonatomic,weak) UIImageView * shopLogoImageView;
@property (nonatomic,weak) UILabel * shopNameLabel;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格
@property (nonatomic,weak) UILabel *numberLabel;
@property (nonatomic,weak) UILabel *returnGoodStatusLabel;

@end

@implementation DRReturnGoodTableViewCell

+ (DRReturnGoodTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ReturnGoodTableViewCellId";
    DRReturnGoodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRReturnGoodTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //店铺logo
    CGFloat shopLogoImageViewWH = 21;
    CGFloat shopLogoImageViewY = (35 - shopLogoImageViewWH) / 2 + 9;
    UIImageView * shopLogoImageView = [[UIImageView alloc] init];
    self.shopLogoImageView = shopLogoImageView;
    shopLogoImageView.frame = CGRectMake(DRMargin, shopLogoImageViewY, shopLogoImageViewWH, shopLogoImageViewWH);
    shopLogoImageView.contentMode = UIViewContentModeScaleAspectFill;
    shopLogoImageView.layer.masksToBounds = YES;
    shopLogoImageView.layer.cornerRadius = shopLogoImageView.width / 2;
    [self addSubview:shopLogoImageView];
    
    //店铺名称
    UILabel * shopNameLabel = [[UILabel alloc] init];
    self.shopNameLabel = shopNameLabel;
    CGFloat shopNameLabelX = CGRectGetMaxX(shopLogoImageView.frame) + 10;
    shopNameLabel.frame = CGRectMake(shopNameLabelX, 9, screenWidth - shopNameLabelX, 35);
    shopNameLabel.textColor = DRBlackTextColor;
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:shopNameLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 9 + 35, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line1.frame) + 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
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
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 9 + 35 + 100, screenWidth, 40)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [bottomView addSubview:line2];
    
    //订单编号
    UILabel * numberLabel = [[UILabel alloc] init];
    self.numberLabel = numberLabel;
    numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    numberLabel.textColor = DRGrayTextColor;
    [bottomView addSubview:numberLabel];

    //退款状态
    UILabel *returnGoodStatusLabel = [[UILabel alloc] init];
    self.returnGoodStatusLabel = returnGoodStatusLabel;
    returnGoodStatusLabel.text = @"未知状态";
    returnGoodStatusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    returnGoodStatusLabel.textColor = DRGrayTextColor;
    [bottomView addSubview:returnGoodStatusLabel];
}

- (void)returnGoodButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(returnGoodTableViewCell:returnGoodButtonDidClick:)]) {
        [_delegate returnGoodTableViewCell:self returnGoodButtonDidClick:button];
    }
}

#pragma mark - 设置数据
- (void)setReturnGoodModel:(DRReturnGoodModel *)returnGoodModel
{
    _returnGoodModel = returnGoodModel;
    
    NSString * logoUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_returnGoodModel.store.storeImg];
    [self.shopLogoImageView sd_setImageWithURL:[NSURL URLWithString:logoUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.shopNameLabel.text = _returnGoodModel.store.storeName;
    
    if (DRObjectIsEmpty(_returnGoodModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _returnGoodModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _returnGoodModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX - DRMargin;
    if (DRStringIsEmpty(_returnGoodModel.goods.description_)) {
        self.goodNameLabel.text = _returnGoodModel.goods.name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(labelW, 40)];
        self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y + 5, labelW, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _returnGoodModel.goods.name, _returnGoodModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _returnGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( _returnGoodModel.goods.name.length, nameAttStr.length - _returnGoodModel.goods.name.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(labelW, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(labelX, self.goodImageView.y + 5, labelW, goodNameLabelSize.height);
    }
   
    if (DRObjectIsEmpty(_returnGoodModel.specification)) {
        self.goodSpecificationLabel.hidden = YES;
    }else
    {
        self.goodSpecificationLabel.hidden = NO;
        self.goodSpecificationLabel.text = _returnGoodModel.specification.name;
        CGSize goodSpecificationLabelSize = [self.goodSpecificationLabel.text sizeWithLabelFont:self.goodSpecificationLabel.font];
        CGFloat goodSpecificationLabelH = goodSpecificationLabelSize.height + 4;
        self.goodSpecificationLabel.frame = CGRectMake(labelX, CGRectGetMaxY(self.goodNameLabel.frame) + 10, goodSpecificationLabelSize.width + 15, goodSpecificationLabelH);
        self.goodSpecificationLabel.layer.cornerRadius = goodSpecificationLabelH / 2;
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"订单编号：%@", _returnGoodModel.orderId];
    CGSize numberLabelSize = [self.numberLabel.text sizeWithLabelFont:self.numberLabel.font];
    self.numberLabel.frame = CGRectMake(DRMargin, 0, numberLabelSize.width, 40);
    
    self.returnGoodStatusLabel.textColor = DRDefaultColor;
    if ([_returnGoodModel.status intValue] == 0) {
        self.returnGoodStatusLabel.text = @"未退款";
    }else
    {
        if ([_returnGoodModel.status intValue] == 10) {
            self.returnGoodStatusLabel.text = @"待审核退款";
        }else if ([_returnGoodModel.status intValue] == 20) {
            self.returnGoodStatusLabel.text = @"审核通过";
        }else if ([_returnGoodModel.status intValue] == -1) {
            self.returnGoodStatusLabel.text = @"驳回";
        }else if ([_returnGoodModel.status intValue] == 100) {
            self.returnGoodStatusLabel.text = @"已退款";
        }else
        {
            self.returnGoodStatusLabel.text = @"未知状态";
            self.returnGoodStatusLabel.textColor = DRGrayTextColor;
        }
    }
    
    CGSize returnGoodStatusLabelSize = [self.returnGoodStatusLabel.text sizeWithLabelFont:self.returnGoodStatusLabel.font];
    self.returnGoodStatusLabel.frame = CGRectMake(screenWidth - DRMargin - returnGoodStatusLabelSize.width, 0, returnGoodStatusLabelSize.width, 40);
}

@end
