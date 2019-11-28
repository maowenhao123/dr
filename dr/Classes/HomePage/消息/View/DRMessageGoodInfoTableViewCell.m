//
//  DRMessageGoodInfoTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/12/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRMessageGoodInfoTableViewCell.h"
#import "EaseBubbleView+MessageGoodInfo.h"

static const CGFloat kCellHeight = 180.0f;

@implementation DRMessageGoodInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self) {
        self.avatarSize = 40;
        self.avatarCornerRadius = 20;
        self.hasRead.hidden = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}
- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}
- (void)setCustomModel:(id<IMessageModel>)model
{
    UIImage *image = model.image;
    if (!image) {
        [self.bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:[UIImage imageNamed:model.failImageName]];
    } else {
        _bubbleView.imageView.image = image;
    }
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}
- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setUpShareBubbleView];
    
    _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
}
- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateShareMargin:bubbleMargin];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat bubbleViewHeight = 100;// 气泡背景图高度
    CGFloat bubbleViewWeight = screenWidth - 55 - 30;
    CGFloat nameLabelHeight = 15;// 昵称label的高度
    if (model.isSender) {
        _bubbleView.frame =
        CGRectMake(30, nameLabelHeight, bubbleViewWeight, bubbleViewHeight);
    }else{
        _bubbleView.frame = CGRectMake(55, nameLabelHeight, bubbleViewWeight, bubbleViewHeight);
    }
    // 这里强制调用内部私有方法
    [_bubbleView _setUpShareBubbleMarginConstraints];
}
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return kCellHeight;
}
- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    
    _bubbleView.isSender = model.isSender;
    NSDictionary *ext = [[NSDictionary alloc]initWithDictionary:model.message.ext];
    //发送了商品信息的情况
    NSDictionary *goodsInfo = [DRTool dictionaryWithJsonString:ext[@"ProductMessage"]];
    if (!DRDictIsEmpty(goodsInfo)) {
        _bubbleView.titleLabel.text = goodsInfo[@"name"];
        _bubbleView.content.text = goodsInfo[@"description"];
        _bubbleView.priceLabel.text = goodsInfo[@"price"];
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@%@",baseUrl, goodsInfo[@"spreadPics"], smallPicUrl];
        [_bubbleView.imageViewShare sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    _hasRead.hidden = YES;//名片消息不显示已读
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSString *imageName = self.model.isSender ? @"RedpacketCellResource.bundle/redpacket_sender_bg" : @"RedpacketCellResource.bundle/redpacket_receiver_bg";
    [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:20 topCapHeight:35];

}

@end
