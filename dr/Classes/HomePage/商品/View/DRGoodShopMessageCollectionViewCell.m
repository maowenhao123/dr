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
    goShopButton.frame = CGRectMake(screenWidth - (80 + DRMargin), CGRectGetMaxY(lineView.frame) + (80 - 30) / 2, 80, 30);
    [goShopButton setTitle:@"进店逛逛" forState:UIControlStateNormal];
    goShopButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
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
    
    self.shopNameLabel.text = _store.storeName;

    NSMutableAttributedString * shopMessageAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"店铺销量：%@  关注人数：%@", [DRTool getNumber:_store.sellCount], [DRTool getNumber:_store.fansCount]]];
    [shopMessageAttStr addAttribute:NSFontAttributeName value:self.shopMessageLabel.font range:NSMakeRange(0, shopMessageAttStr.length)];
    self.shopMessageLabel.attributedText = shopMessageAttStr;
    
    CGFloat viewX = CGRectGetMaxX(self.shopAvatarImageView.frame) + DRMargin;
    CGFloat maxWidth = screenWidth - viewX - (80 - DRMargin * 2);
    CGSize shopNameLabelSize = [self.shopNameLabel.text sizeWithFont:self.shopNameLabel.font maxSize:CGSizeMake(maxWidth, MAXFLOAT)];
    self.shopNameLabel.frame = CGRectMake(viewX, 9 + 10 + 7, shopNameLabelSize.width, shopNameLabelSize.height);
    
    CGSize shopMessageLabelSize = [self.shopMessageLabel.attributedText boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.shopMessageLabel.frame = CGRectMake(viewX, 90 - 10 - 7 - shopMessageLabelSize.height, shopMessageLabelSize.width, shopMessageLabelSize.height);
    
}



@end
