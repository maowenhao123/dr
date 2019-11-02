//
//  DRReturnGoodManageTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodManageTableViewCell.h"

@interface DRReturnGoodManageTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodSpecificationLabel;//商品规格
@property (nonatomic,weak) UIButton *returnGoodButton;

@end

@implementation DRReturnGoodManageTableViewCell

+ (DRReturnGoodManageTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ReturnGoodManageTableViewCellId";
    DRReturnGoodManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRReturnGoodManageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 12, 76, 76)];
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
    
    // 退款
    UIButton *returnGoodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.returnGoodButton = returnGoodButton;
    CGFloat returnGoodButtonW = 70;
    CGFloat returnGoodButtonH = 26;
    self.returnGoodButton.frame = CGRectMake(screenWidth - DRMargin - returnGoodButtonW, CGRectGetMaxY(self.goodImageView.frame) - returnGoodButtonH, returnGoodButtonW, returnGoodButtonH);
    returnGoodButton.backgroundColor = DRDefaultColor;
    [returnGoodButton setTitle:@"未知状态" forState:UIControlStateNormal];
    [returnGoodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    returnGoodButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [returnGoodButton addTarget:self action:@selector(returnGoodButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    returnGoodButton.layer.masksToBounds = YES;
    returnGoodButton.layer.cornerRadius = 4;
    [self addSubview:returnGoodButton];
}
- (void)returnGoodButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(returnGoodManageTableViewCell:buttonDidClick:)]) {
        [_delegate returnGoodManageTableViewCell:self buttonDidClick:button];
    }
}
- (void)setReturnGoodModel:(DRReturnGoodModel *)returnGoodModel
{
    _returnGoodModel = returnGoodModel;
    
    if (DRObjectIsEmpty(self.returnGoodModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _returnGoodModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, _returnGoodModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        self.goodSpecificationLabel.text = self.returnGoodModel.specification.name;
    }
    
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    if (DRStringIsEmpty(_returnGoodModel.goods.description_)) {
        self.goodNameLabel.text = _returnGoodModel.goods.name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(screenWidth - goodNameLabelX - 10, 40)];
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _returnGoodModel.goods.name, _returnGoodModel.goods.description_]];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _returnGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( _returnGoodModel.goods.name.length, nameAttStr.length - _returnGoodModel.goods.name.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - goodNameLabelX - 10, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }
    
    if (DRObjectIsEmpty(_returnGoodModel.specification)) {
        self.goodSpecificationLabel.hidden = YES;
    }else
    {
        self.goodSpecificationLabel.hidden = NO;
        self.goodSpecificationLabel.text = _returnGoodModel.specification.name;
        CGSize goodSpecificationLabelSize = [self.goodSpecificationLabel.text sizeWithLabelFont:self.goodSpecificationLabel.font];
        CGFloat goodSpecificationLabelH = goodSpecificationLabelSize.height + 4;
        self.goodSpecificationLabel.frame = CGRectMake(self.goodNameLabel.x, CGRectGetMaxY(self.goodNameLabel.frame) + 10, goodSpecificationLabelSize.width + 15, goodSpecificationLabelH);
        self.goodSpecificationLabel.layer.cornerRadius = goodSpecificationLabelH / 2;
    }
    
    if ([_returnGoodModel.status intValue] == 10) {
        self.returnGoodButton.backgroundColor = DRDefaultColor;
        self.returnGoodButton.enabled = YES;
        [self.returnGoodButton setTitle:@"退款处理" forState:UIControlStateNormal];
    }else
    {
        self.returnGoodButton.backgroundColor = [UIColor lightGrayColor];
        self.returnGoodButton.enabled = NO;
        if ([_returnGoodModel.status intValue] == 20) {
            [self.returnGoodButton setTitle:@"审核通过" forState:UIControlStateNormal];
        }else if ([_returnGoodModel.status intValue] == -1) {
            [self.returnGoodButton setTitle:@"驳回" forState:UIControlStateNormal];
        }else if ([_returnGoodModel.status intValue] == 100) {
            [self.returnGoodButton setTitle:@"已退款" forState:UIControlStateNormal];
        }else {
            [self.returnGoodButton setTitle:@"未知状态" forState:UIControlStateNormal];
        }
    }
    
}

@end
