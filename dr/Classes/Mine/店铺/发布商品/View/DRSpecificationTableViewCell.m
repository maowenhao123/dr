//
//  DRSpecificationTableViewCell.m
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRSpecificationTableViewCell.h"

@interface DRSpecificationTableViewCell ()

@property (nonatomic,weak) UILabel * indexLabel;
@property (nonatomic,weak) UIButton * editButton;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodPlusCountLabel;//商品编号
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格
@property (nonatomic,weak) UIButton * deleteButton;

@end

@implementation DRSpecificationTableViewCell

+ (DRSpecificationTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SpecificationTableViewCellId";
    DRSpecificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSpecificationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    
    //规格名称
    CGFloat buttonW = 80;
    UILabel * indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9, screenWidth - 2 * DRMargin - buttonW, 40)];
    self.indexLabel = indexLabel;
    indexLabel.textColor = DRBlackTextColor;
    indexLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:indexLabel];
    
    //编辑
    UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(screenWidth - buttonW - DRMargin, 9, buttonW, 40);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [editButton addTarget:self action:@selector(editButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:editButton];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(indexLabel.frame), screenWidth, 1)];
    line.backgroundColor = DRBackgroundColor;
    [self addSubview:line];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line.frame) + 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    CGFloat labelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    CGFloat labelW = screenWidth - labelX - DRMargin;
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(line.frame) + 12, labelW, 20)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(line.frame) + 12 + (76 - 20) / 2, labelW, 20)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:goodPriceLabel];
    
    //商品数量
    UILabel * goodPlusCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(line.frame) + 12 + (76 - 20), labelW - 80, 20)];
    self.goodPlusCountLabel = goodPlusCountLabel;
    goodPlusCountLabel.textColor = DRBlackTextColor;
    goodPlusCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodPlusCountLabel];
    
    //删除
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(screenWidth - buttonW - DRMargin, CGRectGetMaxY(line.frame) + 12 + (76 - 20), buttonW, 20);
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:DRRedTextColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [deleteButton addTarget:self action:@selector(deleteButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
}

- (void)editButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(specificationTableViewCell:editButtonDidClick:)]) {
        [_delegate specificationTableViewCell:self editButtonDidClick:button];
    }
}

- (void)deleteButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(specificationTableViewCell:deleteButtonDidClick:)]) {
        [_delegate specificationTableViewCell:self deleteButtonDidClick:button];
    }
}

- (void)setGoodSpecificationModel:(DRGoodSpecificationModel *)goodSpecificationModel
{
    _goodSpecificationModel = goodSpecificationModel;
    
    self.indexLabel.text = [NSString stringWithFormat:@"规格%ld", _goodSpecificationModel.index_ + 1];
    if (_goodSpecificationModel.pic) {
        self.goodImageView.image = _goodSpecificationModel.pic;
    }else
    {
        NSString * picUrl = [NSString stringWithFormat:@"%@", _goodSpecificationModel.picUrl];
        NSString * imageUrlStr = @"";
        if ([picUrl containsString:@"http"]) {
            imageUrlStr = picUrl;
        }else
        {
            imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, picUrl, smallPicUrl];
        }
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    self.goodNameLabel.text = [NSString stringWithFormat:@"名称：%@", _goodSpecificationModel.name];
    self.goodPlusCountLabel.text = [NSString stringWithFormat:@"库存：%@", _goodSpecificationModel.storeCount];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"价格：%@", _goodSpecificationModel.price];
}

@end
