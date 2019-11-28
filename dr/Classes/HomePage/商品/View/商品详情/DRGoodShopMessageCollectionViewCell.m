//
//  DRGoodShopMessageCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/1/23.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGoodShopMessageCollectionViewCell.h"
#import "DRShopDetailViewController.h"

@interface DRGoodShopMessageCollectionViewCell ()

@property (nonatomic, weak) UIImageView * shopAvatarImageView;
@property (nonatomic, weak) UILabel * shopNameLabel;
@property (nonatomic, weak) UILabel * shopMessageLabel;
@property (nonatomic, weak) UIButton * goShopButton;

@end

@implementation DRGoodShopMessageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //头像
    UIImageView * shopAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 10, 60, 60)];
    self.shopAvatarImageView = shopAvatarImageView;
    shopAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    shopAvatarImageView.layer.masksToBounds = YES;
    shopAvatarImageView.layer.cornerRadius = shopAvatarImageView.width / 2;
    [self addSubview:shopAvatarImageView];
    
    //店名
    UILabel * shopNameLabel = [[UILabel alloc] init];
    self.shopNameLabel = shopNameLabel;
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    shopNameLabel.textColor = DRBlackTextColor;
    shopNameLabel.numberOfLines = 0;
    [self addSubview:shopNameLabel];
    
    //店铺信息
    UILabel * shopMessageLabel = [[UILabel alloc] init];
    self.shopMessageLabel = shopMessageLabel;
    shopMessageLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    shopMessageLabel.textColor = DRGrayTextColor;
    shopMessageLabel.numberOfLines = 0;
    [self addSubview:shopMessageLabel];
    
    //进店逛逛
    UIButton * goShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.goShopButton = goShopButton;
    [goShopButton setTitle:@"进店逛逛" forState:UIControlStateNormal];
    goShopButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    goShopButton.layer.masksToBounds = YES;
    goShopButton.layer.cornerRadius = 4;
    goShopButton.layer.borderWidth = 1;
    [goShopButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    goShopButton.layer.borderColor = DRDefaultColor.CGColor;
    [goShopButton addTarget:self action:@selector(goShopButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goShopButton];
}

- (void)goShopButtonDidClick
{
    DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
    shopVC.shopId = self.store.id;
    [self.viewController.navigationController pushViewController:shopVC animated:YES];
}

- (void)setStore:(DRShopModel *)store
{
    _store = store;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _store.storeImg];
    [self.shopAvatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    //店铺名
    if (!DRStringIsEmpty(_store.storeName)) {
        NSMutableAttributedString * shopNameAttStr = [[NSMutableAttributedString alloc] initWithString:_store.storeName];
        NSAttributedString * spaceAttStr = [[NSAttributedString alloc] initWithString:@" "];
        for (NSString * tag in _store.tags) {
            NSURL * imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, tag]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageUrl];
            NSTextAttachment *certificationTextAttachment = [[NSTextAttachment alloc] init];
            UIImage * image = [UIImage imageWithData:imageData];
            CGFloat certificationTextAttachmentH = self.shopNameLabel.font.pointSize - 1;
            if ([tag containsString:@"base_authentication_yes"])
            {
                certificationTextAttachmentH = self.shopNameLabel.font.pointSize + 4;
            }
            CGFloat certificationTextAttachmentW = image.size.width * (certificationTextAttachmentH / image.size.height);
            certificationTextAttachment.bounds = CGRectMake(0, -1 + (self.shopNameLabel.font.pointSize - certificationTextAttachmentH) / 2, certificationTextAttachmentW, certificationTextAttachmentH);
            certificationTextAttachment.image = image;
            NSAttributedString *certificationTextAttStr = [NSAttributedString attributedStringWithAttachment:certificationTextAttachment];
            [shopNameAttStr appendAttributedString:spaceAttStr];
            [shopNameAttStr appendAttributedString:certificationTextAttStr];
        }
        self.shopNameLabel.attributedText = shopNameAttStr;
    }
    
    NSMutableAttributedString * shopMessageAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"店铺销量：%@  关注人数：%@", [DRTool getNumber:_store.sellCount], [DRTool getNumber:_store.fansCount]]];
    [shopMessageAttStr addAttribute:NSFontAttributeName value:self.shopMessageLabel.font range:NSMakeRange(0, shopMessageAttStr.length)];
    self.shopMessageLabel.attributedText = shopMessageAttStr;
    
    CGFloat viewX = CGRectGetMaxX(self.shopAvatarImageView.frame) + DRMargin;
    self.shopNameLabel.frame = CGRectMake(viewX, 9 + 10 + 7, screenWidth - viewX - DRMargin, 20);
    
    CGFloat maxWidth = screenWidth - viewX - (80 - DRMargin * 2);
    CGSize shopMessageLabelSize = [self.shopMessageLabel.attributedText boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.shopMessageLabel.frame = CGRectMake(viewX, 90 - 10 - 7 - shopMessageLabelSize.height, shopMessageLabelSize.width, shopMessageLabelSize.height);
    self.goShopButton.frame = CGRectMake(screenWidth - (75 + DRMargin), 9 + (80 - 28) / 2, 75, 28);
    self.goShopButton.centerY = self.shopMessageLabel.centerY;
    
}



@end
