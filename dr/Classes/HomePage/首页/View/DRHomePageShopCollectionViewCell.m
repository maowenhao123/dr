//
//  DRHomePageShopCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageShopCollectionViewCell.h"
#import "DRShopDetailViewController.h"
#import "DRGoodDetailViewController.h"

@interface DRHomePageShopCollectionViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *sellCountLabel;
@property (nonatomic, weak) UIImageView * bigImageView;
@property (nonatomic, weak) UIImageView * smallImageView1;
@property (nonatomic, weak) UIImageView * smallImageView2;

@end

@implementation DRHomePageShopCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line.frame) + 9, 36, 36)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //店名
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, CGRectGetMaxY(line.frame) + 7, 150, 20)];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    nameLabel.textColor = DRBlackTextColor;
    [self addSubview:nameLabel];
    
    //销量
    UILabel * sellCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.x, CGRectGetMaxY(nameLabel.frame), 100, 20)];
    self.sellCountLabel = sellCountLabel;
    sellCountLabel.textColor = DRGrayTextColor;
    sellCountLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:sellCountLabel];
    
    //进店看看
    UIButton * goShopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goShopButton setTitle:@"进店看看>" forState:UIControlStateNormal];
    [goShopButton setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
    goShopButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    CGSize goShopButtonSize = [goShopButton.currentTitle sizeWithLabelFont:goShopButton.titleLabel.font];
    goShopButton.frame = CGRectMake(screenWidth - DRMargin - goShopButtonSize.width, CGRectGetMaxY(line.frame), goShopButtonSize.width, 53);
    [goShopButton addTarget:self action:@selector(goShopButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goShopButton];
    
    //图片
    CGFloat padding = 5;
    CGFloat smallImageViewWH = (screenWidth -  4 * padding) / 3;
    CGFloat bigImageViewWH = 2 * smallImageViewWH + padding;
    
    for (int i = 0; i < 3; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        if (i == 0) {
            self.bigImageView = imageView;
            imageView.frame = CGRectMake(padding, 53, bigImageViewWH, bigImageViewWH);
        }else if (i == 1)
        {
            self.smallImageView1 = imageView;
            imageView.frame = CGRectMake(CGRectGetMaxX(self.bigImageView.frame) + padding, 53, smallImageViewWH, smallImageViewWH);
        }else if (i == 2)
        {
            self.smallImageView2 = imageView;
            imageView.frame = CGRectMake(self.smallImageView1.x, CGRectGetMaxY(self.smallImageView1.frame) + padding, smallImageViewWH, smallImageViewWH);
        }
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"shop_no_good"];
        [self addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goodDidClick:)];
        [imageView addGestureRecognizer:tap];
    }
}

- (void)goShopButtonDidClick
{
    DRShopDetailViewController * shopVC = [[DRShopDetailViewController alloc] init];
    shopVC.shopId = self.model.id;
    [self.viewController.navigationController pushViewController:shopVC animated:YES];
}

- (void)goodDidClick:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    if (tag + 1 > self.model.recommendGoods.count) {
        return;
    }
    DRGoodModel * goodModel = self.model.recommendGoods[tag];
    DRGoodDetailViewController * goodVC = [[DRGoodDetailViewController alloc] init];
    goodVC.goodId = goodModel.id;
    [self.viewController.navigationController pushViewController:goodVC animated:YES];
}

- (void)setModel:(DRShopModel *)model
{
    _model = model;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_model.storeImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.nameLabel.text = _model.storeName;
    self.sellCountLabel.text = [NSString stringWithFormat:@"销量：%@",_model.sellCount];
    self.bigImageView.image = [UIImage imageNamed:@"shop_no_good"];
    self.smallImageView1.image = [UIImage imageNamed:@"shop_no_good"];
    self.smallImageView2.image = [UIImage imageNamed:@"shop_no_good"];
    for (int i = 0; i < self.model.recommendGoods.count; i++) {
        DRGoodModel * goodModel = self.model.recommendGoods[i];
        NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,goodModel.spreadPics,smallPicUrl];
        if (i == 0) {
            [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }else if (i == 1)
        {
            [self.smallImageView1 sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }else if (i == 2)
        {
            [self.smallImageView2 sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"shop_no_good"]];
        }
    }
}

@end
