//
//  DROrderGroupTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DROrderGroupTableViewCell.h"
#import "DRGrouponProgressView.h"

@interface DROrderGroupTableViewCell ()

@property (nonatomic,weak) UIImageView * logoImageView;
@property (nonatomic,weak) UILabel * shopNameLabel;
@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UILabel *goodCountLabel;//商品数量
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格
@property (nonatomic, weak) DRGrouponProgressView *progressView;//进度

@end

@implementation DROrderGroupTableViewCell

+ (DROrderGroupTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderGroupTableViewCellId";
    DROrderGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DROrderGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 10, 80, 80)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc]init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRRedTextColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:goodPriceLabel];
    
    //商品数量
    UILabel * goodCountLabel = [[UILabel alloc] init];
    self.goodCountLabel = goodCountLabel;
    goodCountLabel.textColor = DRBlackTextColor;
    goodCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:goodCountLabel];
    
    //进度条
    DRGrouponProgressView *progressView = [[DRGrouponProgressView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.goodImageView.frame) + DRMargin, CGRectGetMaxY(goodImageView.frame) - 9, 80, 9)];
    self.progressView = progressView;
    progressView.progress = 65;
    [self addSubview:progressView];
}
- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    DRStoreOrderModel * storeOrderModel= _orderModel.storeOrders.firstObject;
    DROrderItemDetailModel * orderItemDetailModel = storeOrderModel.detail.firstObject;
    
    //赋值
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,storeOrderModel.storeImg];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    self.shopNameLabel.text = storeOrderModel.storeName;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,orderItemDetailModel.goods.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (DRStringIsEmpty(orderItemDetailModel.goods.description_)) {
        self.goodNameLabel.text = orderItemDetailModel.goods.name;
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ %@", orderItemDetailModel.goods.name, orderItemDetailModel.goods.description_]];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
        textAttachment.bounds = CGRectMake(0, -4, 32, 16);
        textAttachment.image = [UIImage imageNamed:@"order_groupon_icon"];
        NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [nameAttStr insertAttributedString:textAttachmentString atIndex:0];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, orderItemDetailModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( orderItemDetailModel.goods.name.length, nameAttStr.length - orderItemDetailModel.goods.name.length)];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 1;//行间距
        [nameAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, nameAttStr.length)];
        self.goodNameLabel.attributedText = nameAttStr;
    }
    
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@",[DRTool formatFloat:[_orderModel.group.price doubleValue] / 100]];
    self.goodCountLabel.text = [NSString stringWithFormat:@"%@个起团 - 已团%d", _orderModel.group.successCount,  [_orderModel.group.payCount intValue]];
    //进度条
    self.progressView.progress = [_orderModel.group.payCount intValue] / [_orderModel.group.successCount doubleValue] * 100;
    
    //frame
    CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
    self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y - 2, screenWidth - CGRectGetMaxX(self.goodImageView.frame) - DRMargin - 5, 37);
    
    CGSize goodPriceLabelSize = [self.goodPriceLabel.text sizeWithLabelFont:self.goodPriceLabel.font];
    CGFloat goodPriceLabelY = CGRectGetMaxY(self.goodNameLabel.frame);
    CGFloat goodPriceLabelW = goodPriceLabelSize.width;
    self.goodPriceLabel.frame = CGRectMake(goodNameLabelX, goodPriceLabelY, goodPriceLabelW, goodPriceLabelSize.height);
    
    CGSize goodCountLabelSize = [self.goodCountLabel.text sizeWithLabelFont:self.goodCountLabel.font];
    self.goodCountLabel.frame = CGRectMake(goodNameLabelX, CGRectGetMaxY(self.goodPriceLabel.frame) + 5, goodCountLabelSize.width, goodCountLabelSize.height);
    self.progressView.y =  CGRectGetMaxY(self.goodCountLabel.frame) + 5;
    
}

@end
