//
//  DROrderSingleTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/5/26.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderSingleTableViewCell.h"

@interface DROrderSingleTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称

@end

@implementation DROrderSingleTableViewCell

+ (DROrderSingleTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderSingleTableViewCellId";
    DROrderSingleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DROrderSingleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + DRMargin, goodImageView.y, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + DRMargin), goodImageView.height)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];
}

#pragma mark - 设置数据
- (void)setStoreOrderModel:(DRStoreOrderModel *)storeOrderModel
{
    _storeOrderModel = storeOrderModel;
    
    //赋值
    DROrderItemDetailModel * orderItemDetailModel = _storeOrderModel.detail.firstObject;
    if (DRObjectIsEmpty(orderItemDetailModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, orderItemDetailModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (DRStringIsEmpty(orderItemDetailModel.goods.description_)) {
        self.goodNameLabel.text = orderItemDetailModel.goods.name;
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", orderItemDetailModel.goods.name, orderItemDetailModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, orderItemDetailModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( orderItemDetailModel.goods.name.length, nameAttStr.length - orderItemDetailModel.goods.name.length)];
        self.goodNameLabel.attributedText = nameAttStr;
    }
}

@end
