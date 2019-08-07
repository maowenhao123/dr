//
//  DRGoodItemView.m
//  dr
//
//  Created by dahe on 2019/8/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodItemView.h"

@interface DRGoodItemView ()

@property (nonatomic, weak) UIImageView * goodImageView;
@property (nonatomic, weak) UILabel * goodNameLabel;
@property (nonatomic, weak) UILabel * goodPriceLabel;

@end

@implementation DRGoodItemView

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
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    CGFloat width = self.width;
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //名字
    UILabel * goodNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goodImageView.frame) + 5, width - 2 * 10, 40)];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    [self addSubview:goodNameLabel];
    
    //价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(goodNameLabel.frame), width - 2 * 10, 25)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    goodPriceLabel.textColor = DRRedTextColor;
    [self addSubview:goodPriceLabel];
    
    self.goodImageView.backgroundColor = [UIColor redColor];
    self.goodNameLabel.text = @"商品名称";
    self.goodPriceLabel.text = @"12.34";
}

@end
