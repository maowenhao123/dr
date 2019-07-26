//
//  DRPublishWholesaleGoodView.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRPublishWholesaleGoodView.h"
#import "DRBottomPickerView.h"

@interface DRPublishWholesaleGoodView ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIPickerView * pickView;
@property (nonatomic, strong) NSArray *sortArray1;
@property (nonatomic, strong) NSArray *sortArray2;
@property (nonatomic, assign) NSInteger selectedIndex1;
@property (nonatomic, assign) NSInteger selectedIndex2;
@property (nonatomic, weak) UILabel * grouponPriceLabel;
@property (nonatomic, weak) UIView *groupExplainView;

@end

@implementation DRPublishWholesaleGoodView

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
   
    UIView * lastView;
    for (int i = 0; i < 3; i++) {
        CGFloat viewY = (DRCellH + 1) * i;
        UILabel * wordLabel1 = [[UILabel alloc] init];
        wordLabel1.text = @"满";
        wordLabel1.textColor = DRBlackTextColor;
        wordLabel1.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel1Size = [wordLabel1.text sizeWithLabelFont:wordLabel1.font];
        wordLabel1.frame = CGRectMake(DRMargin, viewY, wordLabel1Size.width, DRCellH);
        [self addSubview:wordLabel1];
        
        UITextField * numberTF = [[UITextField alloc] init];
        if (i == 0) {
            self.numberTF1 = numberTF;
        }else if (i == 1)
        {
            self.numberTF2 = numberTF;
        }else if (i == 2)
        {
            self.numberTF3 = numberTF;
        }
        numberTF.textColor = DRBlackTextColor;
        numberTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        numberTF.tintColor = DRDefaultColor;
        numberTF.borderStyle = UITextBorderStyleRoundedRect;
        numberTF.textAlignment = NSTextAlignmentCenter;
        numberTF.keyboardType = UIKeyboardTypeNumberPad;
        numberTF.frame = CGRectMake(CGRectGetMaxX(wordLabel1.frame) + 5, viewY + 7, 75, DRCellH - 2 * 7);
        [self addSubview:numberTF];
        
        UILabel * wordLabel2 = [[UILabel alloc] init];
        wordLabel2.text = @"个 -> 单价";
        wordLabel2.textColor = DRBlackTextColor;
        wordLabel2.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel2Size = [wordLabel2.text sizeWithLabelFont:wordLabel2.font];
        wordLabel2.frame = CGRectMake(CGRectGetMaxX(numberTF.frame) + 5, viewY, wordLabel2Size.width, DRCellH);
        [self addSubview:wordLabel2];
        
        DRDecimalTextField * priceTF = [[DRDecimalTextField alloc] init];
        if (i == 0) {
            self.priceTF1 = priceTF;
        }else if (i == 1)
        {
            self.priceTF2 = priceTF;
        }else if (i == 2)
        {
            self.priceTF3 = priceTF;
        }
        priceTF.textColor = DRBlackTextColor;
        priceTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        priceTF.tintColor = DRDefaultColor;
        priceTF.borderStyle = UITextBorderStyleRoundedRect;
        priceTF.textAlignment = NSTextAlignmentCenter;
        
        priceTF.frame = CGRectMake(CGRectGetMaxX(wordLabel2.frame) + 5, viewY + 7, 75, DRCellH - 2 * 7);
        [self addSubview:priceTF];
        
        UILabel * wordLabel3 = [[UILabel alloc] init];
        wordLabel3.text = @"元";
        wordLabel3.textColor = DRBlackTextColor;
        wordLabel3.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize wordLabel3Size = [wordLabel3.text sizeWithLabelFont:wordLabel3.font];
        wordLabel3.frame = CGRectMake(CGRectGetMaxX(priceTF.frame) + 5, viewY, wordLabel3Size.width, DRCellH);
        [self addSubview:wordLabel3];
        lastView = wordLabel3;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, DRCellH * i, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [self addSubview:line];
    }
    
//    //分割线
//    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lastView.frame), screenWidth, 1)];
//    line1.backgroundColor = DRWhiteLineColor;
//    [self addSubview:line1];
//
//    //代理价格
//    UILabel * priceLabel = [[UILabel alloc] init];
//    priceLabel.text = @"代理价格";
//    priceLabel.textColor = DRBlackTextColor;
//    priceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
//    CGSize priceLabelSize = [priceLabel.text sizeWithLabelFont:priceLabel.font];
//    priceLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line1.frame), priceLabelSize.width, DRCellH);
//    [self addSubview:priceLabel];
//
//    DRDecimalTextField * priceTF = [[DRDecimalTextField alloc] init];
//    self.priceTF = priceTF;
//    CGFloat priceTFX = CGRectGetMaxX(priceLabel.frame) + DRMargin;
//    priceTF.frame = CGRectMake(priceTFX, CGRectGetMaxY(line1.frame), screenWidth - priceTFX - DRMargin, DRCellH);
//    priceTF.textColor = DRBlackTextColor;
//    priceTF.textAlignment = NSTextAlignmentRight;
//    priceTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
//    priceTF.tintColor = DRDefaultColor;
//    priceTF.placeholder = @"商品在本平台的结算价格";
//    [self addSubview:priceTF];
    
    //分割线
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lastView.frame), screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [self addSubview:line2];
    
    //库存
    UILabel * countLabel = [[UILabel alloc] init];
    countLabel.text = @"商品库存";
    countLabel.textColor = DRBlackTextColor;
    countLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:countLabel];
    CGSize countLabellSize = [countLabel.text sizeWithLabelFont:countLabel.font];
    countLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line2.frame), countLabellSize.width, DRCellH);
    
    UITextField * countTF = [[UITextField alloc] init];
    self.countTF = countTF;
    CGFloat countTFX = CGRectGetMaxX(countLabel.frame) + DRMargin;
    countTF.frame = CGRectMake(countTFX, CGRectGetMaxY(line2.frame), screenWidth - countTFX - DRMargin, DRCellH);
    countTF.textColor = DRBlackTextColor;
    countTF.textAlignment = NSTextAlignmentRight;
    countTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    countTF.tintColor = DRDefaultColor;
    countTF.keyboardType = UIKeyboardTypeNumberPad;
    countTF.placeholder = @"输入商品库存数";
    [self addSubview:countTF];
    
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(countLabel.frame), screenWidth, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [self addSubview:line3];
    
    //团购设置
    UILabel * grouponPriceLabel = [[UILabel alloc] init];
    self.grouponPriceLabel = grouponPriceLabel;
    grouponPriceLabel.text = @"同意一件发货，开启团购";
    grouponPriceLabel.textColor = DRRedTextColor;
    grouponPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize grouponPriceLabelSize = [grouponPriceLabel.text sizeWithLabelFont:grouponPriceLabel.font];
    grouponPriceLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line3.frame), grouponPriceLabelSize.width, DRCellH);
    [self addSubview:grouponPriceLabel];
    
    UISwitch *grouponSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    // 控件大小，不能设置frame，只能用缩放比例
    self.grouponSwitch = grouponSwitch;
    grouponSwitch.on = NO;
    CGFloat scale = 0.8;
    grouponSwitch.transform = CGAffineTransformMakeScale(scale, scale);
    grouponSwitch.x = screenWidth - grouponSwitch.width - DRMargin;
    grouponSwitch.y = CGRectGetMaxY(line3.frame) + (DRCellH - grouponSwitch.height * scale) / 2;
    grouponSwitch.onTintColor = DRDefaultColor;
    [grouponSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:grouponSwitch];
    
    //团购说明
    UIView *groupExplainView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(grouponPriceLabel.frame), screenWidth, 0)];
    self.groupExplainView = groupExplainView;
    groupExplainView.backgroundColor = [UIColor whiteColor];
    groupExplainView.hidden = YES;
    [self addSubview:groupExplainView];
    
    UIView * line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line4.backgroundColor = DRWhiteLineColor;
    [groupExplainView addSubview:line4];

    UILabel * groupExplainLabel = [[UILabel alloc] init];
    groupExplainLabel.text = @"团购说明：\n1、开启团购后，团购商品由您直接发货给买家，且表示您同意一件发货。\n2、团购数量为最低批发数量，团购价格为对应的批发价格。";
    groupExplainLabel.textColor = DRBlackTextColor;
    groupExplainLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    groupExplainLabel.numberOfLines = 0;
    CGSize groupExplainLabelSize = [groupExplainLabel.text sizeWithFont:groupExplainLabel.font maxSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT)];
    groupExplainLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line4.frame), groupExplainLabelSize.width, groupExplainLabelSize.height + 20);
    [groupExplainView addSubview:groupExplainLabel];
    groupExplainView.height = CGRectGetMaxY(groupExplainLabel.frame);
    
    self.height = CGRectGetMaxY(grouponPriceLabel.frame);
}

- (void)setIsGroup:(int)isGroup
{
    _isGroup = isGroup;
    
    self.grouponSwitch.on = _isGroup;
    if (_isGroup)
    {
        self.groupExplainView.hidden = NO;
        self.height = CGRectGetMaxY(self.groupExplainView.frame);
    }else
    {
        self.groupExplainView.hidden = YES;
        self.height = CGRectGetMaxY(self.grouponPriceLabel.frame);
    }
    
    if (self.hightChangeBlock) {
        self.hightChangeBlock();
    }
}

- (void)switchAction:(UISwitch *)switchButton
{
    if (switchButton.on)
    {
        double priceFloat1 = [self.priceTF1.text doubleValue];
        double priceFloat2 = [self.priceTF2.text doubleValue];
        double priceFloat3 = [self.priceTF3.text doubleValue];
        int numberInt1 = [self.numberTF1.text intValue];
        int numberInt2 = [self.numberTF2.text intValue];
        int numberInt3 = [self.numberTF3.text intValue];

        if ((DRStringIsEmpty(self.priceTF1.text) || DRStringIsEmpty(self.numberTF1.text)) && (DRStringIsEmpty(self.priceTF2.text) || DRStringIsEmpty(self.numberTF2.text)) && (DRStringIsEmpty(self.priceTF3.text) || DRStringIsEmpty(self.numberTF3.text))) {
            [MBProgressHUD showError:@"未输入批发规则"];
            switchButton.on = NO;
            return;
        }
        if ((priceFloat2 > 0 && priceFloat2 == priceFloat1) || (priceFloat3 > 0 && priceFloat3 == priceFloat2) || (priceFloat3 > 0 && priceFloat3 == priceFloat1)) {
            [MBProgressHUD showError:@"批发规则不正确"];
            switchButton.on = NO;
            return;
        }
        if ((numberInt2 > 0 && numberInt2 == numberInt1) || (numberInt3 > 0 && priceFloat3 == numberInt2) || (numberInt3 > 0 && numberInt3 == numberInt1)) {
            [MBProgressHUD showError:@"批发规则不正确"];
            switchButton.on = NO;
            return;
        }
    }
    self.isGroup = self.grouponSwitch.on;
}


@end
