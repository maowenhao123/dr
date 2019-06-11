//
//  DRShopHeaderCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/10/9.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopHeaderCollectionViewCell.h"

@interface DRShopHeaderCollectionViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;//头像
@property (nonatomic, weak) UILabel * shopNameLabel;//店名
@property (nonatomic,weak) UILabel * detailLabel;
@property (nonatomic,weak) UIView * lineView;
@property (nonatomic,strong) NSMutableArray *labelArray;

@end

@implementation DRShopHeaderCollectionViewCell

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
    UIImageView * backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 202)];
    if (iPhone4 || iPhone5)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_320"];
    }else if (iPhone6 || iPhoneX)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }else if (iPhone6P || iPhoneXR || iPhoneXSMax)
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_414"];
    }else
    {
        backImageView.image = [UIImage imageNamed:@"mine_top_back_375"];
    }
    backImageView.contentMode = UIViewContentModeScaleAspectFill;
    backImageView.userInteractionEnabled = YES;
    [self addSubview:backImageView];

    //头像
    UIImageView * avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 55) / 2, 45, 55, 55)];
    self.avatarImageView = avatarImageView;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
    avatarImageView.layer.borderWidth = 3;
    [backImageView addSubview:avatarImageView];

    //店名
    UILabel * shopNameLabel = [[UILabel alloc] init];
    self.shopNameLabel = shopNameLabel;
    shopNameLabel.textColor = [UIColor whiteColor];
    shopNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    shopNameLabel.textAlignment = NSTextAlignmentCenter;
    shopNameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.avatarImageView.frame) + 12, backImageView.width, shopNameLabel.font.lineHeight);
    [backImageView addSubview:shopNameLabel];

    CGFloat buttonW = 65;
    CGFloat buttonH = 24;
    CGFloat buttonPadding = 50;
    CGFloat buttonX = (screenWidth - buttonPadding - 2 * buttonW) / 2;
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            self.attentionButton = button;
            [button setTitle:@"+关注" forState:UIControlStateNormal];
        }else
        {
            self.chatButton = button;
            [button setTitle:@"聊天" forState:UIControlStateNormal];
        }
        button.frame = CGRectMake(buttonX + (buttonPadding + buttonW) * i, CGRectGetMaxY(self.shopNameLabel.frame) + 13, buttonW, buttonH);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonH / 2;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1;
        [backImageView addSubview:button];
    }

    for (int i = 0; i < 3; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth / 3 * i, 170, screenWidth / 3, 30)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [self.labelArray addObject:label];
    }
    
    //详情
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(backImageView.frame), screenWidth - 2 * DRMargin, 50)];
    self.detailLabel = detailLabel;
    detailLabel.numberOfLines = 0;
    [self addSubview:detailLabel];

    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(detailLabel.frame), screenWidth, 9)];
    self.lineView = lineView;
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
}

- (void)setShopModel:(DRShopModel *)shopModel
{
    _shopModel = shopModel;
    
    if (!_shopModel) {
        return;
    }
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _shopModel.storeImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.shopNameLabel.text = _shopModel.storeName;
    
    NSString * detailStr = _shopModel.description_;
    NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:detailStr];
    [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, detailStr.length)];
    [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, detailStr.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;//行间距
    [detailAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
    self.detailLabel.attributedText = detailAttStr;
    
    for (int i = 0; i < self.labelArray.count; i++) {
        UILabel * label = self.labelArray[i];
        if (i == 0) {
            label.text = [NSString stringWithFormat:@"宝贝%@", _shopModel.goodscount];
        }else if (i == 1)
        {
            label.text = [NSString stringWithFormat:@"销量%@", _shopModel.sellCount];
        }else if (i == 2)
        {
            label.text = [NSString stringWithFormat:@"关注人数%@", _shopModel.fansCount];
        }
    }
    
    //frmae
    CGSize detailLabelSize = [self.detailLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.detailLabel.height = detailLabelSize.height + 16;
    self.lineView.y = CGRectGetMaxY(self.detailLabel.frame);
}

#pragma mark - 初始化
- (NSMutableArray *)labelArray
{
    if (!_labelArray) {
        _labelArray = [NSMutableArray array];
    }
    return _labelArray;
}

@end
