//
//  DRPublishSingleGoodView.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRPublishSingleGoodView.h"
#import "DRBottomPickerView.h"

@implementation DRPublishSingleGoodView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

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
    
    //分割线
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //商品价格
    UILabel * priceLabel = [[UILabel alloc] init];
    priceLabel.text = @"商品价格";
    priceLabel.textColor = DRBlackTextColor;
    priceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:priceLabel];
    CGSize priceLabelSize = [priceLabel.text sizeWithLabelFont:priceLabel.font];
    priceLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line1.frame), priceLabelSize.width, DRCellH);
    
    UILabel * symbolLabel = [[UILabel alloc] init];
    symbolLabel.text = @"元";
    symbolLabel.textColor = DRBlackTextColor;
    symbolLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:symbolLabel];
    CGSize symbolLabelSize = [symbolLabel.text sizeWithLabelFont:symbolLabel.font];
    symbolLabel.frame = CGRectMake(screenWidth - DRMargin - symbolLabelSize.width, CGRectGetMaxY(line1.frame), symbolLabelSize.width, DRCellH);
    
    DRDecimalTextField * priceTF = [[DRDecimalTextField alloc] init];
    self.priceTF = priceTF;
    priceTF.textColor = DRBlackTextColor;
    priceTF.textAlignment = NSTextAlignmentRight;
    priceTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    priceTF.tintColor = DRDefaultColor;
    priceTF.placeholder = @"请输入价格";
    CGFloat priceTFX = CGRectGetMaxX(priceLabel.frame) + DRMargin;
    priceTF.frame = CGRectMake(priceTFX, CGRectGetMaxY(line1.frame), symbolLabel.x - 2 - priceTFX, DRCellH);
    [self addSubview:priceTF];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(priceLabel.frame), screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [self addSubview:line2];
    
    //商品数量
    UILabel * countLabel = [[UILabel alloc] init];
    countLabel.text = @"商品库存";
    countLabel.textColor = DRBlackTextColor;
    countLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:countLabel];
    CGSize countLabelSize = [countLabel.text sizeWithLabelFont:countLabel.font];
    countLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line2.frame), countLabelSize.width, DRCellH);
    
    UITextField * countTF = [[UITextField alloc] init];
    self.countTF = countTF;
    CGFloat countTFX = CGRectGetMaxX(countLabel.frame) + DRMargin;
    countTF.frame = CGRectMake(countTFX, CGRectGetMaxY(line2.frame), screenWidth - countTFX - DRMargin, DRCellH);
    countTF.textColor = DRBlackTextColor;
    countTF.textAlignment = NSTextAlignmentRight;
    countTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    countTF.tintColor = DRDefaultColor;
    countTF.keyboardType = UIKeyboardTypeNumberPad;
    countTF.placeholder = @"请输入商品库存";
    [self addSubview:countTF];
    
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(countLabel.frame), screenWidth, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [self addSubview:line3];

    self.height = CGRectGetMaxY(line3.frame);
}

@end
