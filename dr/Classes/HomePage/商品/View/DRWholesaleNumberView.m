//
//  DRWholesaleNumberView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRWholesaleNumberView.h"
#import "DRAdjustNumberView.h"
#import "UIView+DR.h"

@interface DRWholesaleNumberView ()<DRAdjustNumberViewDelegate>

@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UILabel * stockLabel;
@property (nonatomic,weak) UIButton *selectedNumberButton;
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic,assign) BOOL isBuy;

@end

@implementation DRWholesaleNumberView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel isBuy:(BOOL)isBuy
{
    self = [super initWithFrame:frame];
    if (self) {
        self.goodModel = goodModel;
        self.isBuy = isBuy;
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] init];
    self.goodImageView = goodImageView;
    goodImageView.frame = CGRectMake(DRMargin, -10, 83, 83);
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,self.goodModel.spreadPics,smallPicUrl];
    [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    goodImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    goodImageView.layer.borderWidth = 2;
    goodImageView.layer.masksToBounds = YES;
    goodImageView.layer.cornerRadius = 4;
    [self addSubview:goodImageView];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + 7, 14, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + 7), [UIFont systemFontOfSize:DRGetFontSize(34)].lineHeight)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRDefaultColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    int minCount = 1;
    if ([self.goodModel.sellType intValue] == 2) {
        double minPrice = 0;
        double maxPrice = 0;
        for (NSDictionary * wholesaleRuleDic in _goodModel.wholesaleRule) {
            NSInteger index = [ _goodModel.wholesaleRule indexOfObject:wholesaleRuleDic];
            int price = [wholesaleRuleDic[@"price"] intValue];
            int count = [wholesaleRuleDic[@"count"] intValue];
            if (index == 0) {
                minPrice = price;
                minCount = count;
            }else
            {
                minPrice = price < minPrice ? price : minPrice;
                minCount = count < minCount ? count : minCount;
            }
            maxPrice = price < maxPrice ? maxPrice : price;
        }
        if (maxPrice == minPrice) {
            goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:maxPrice/ 100]];
        }else
        {
            goodPriceLabel.text = [NSString stringWithFormat:@"¥%@ ~ ¥%@", [DRTool formatFloat:maxPrice / 100], [DRTool formatFloat:minPrice / 100]];
        }
    }else
    {
        if ([DRTool showDiscountPriceWithGoodModel:self.goodModel]) {
            NSString * newPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.goodModel.discountPrice doubleValue] / 100]];
            NSString * oldPriceStr = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.goodModel.price doubleValue] / 100]];
            NSString * priceStr = [NSString stringWithFormat:@"%@ %@", newPriceStr, oldPriceStr];
            NSMutableAttributedString * priceAttStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(34)] range:NSMakeRange(0, newPriceStr.length)];
            [priceAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(26)] range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:NSMakeRange(0, newPriceStr.length)];
            [priceAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            [priceAttStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(priceStr.length - oldPriceStr.length, oldPriceStr.length)];
            self.goodPriceLabel.attributedText = priceAttStr;
        }else
        {
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.goodModel.price doubleValue] / 100]];
        }
    }
    [self addSubview:goodPriceLabel];
    
    //plusCount
    //库存
    UILabel * stockLabel = [[UILabel alloc] init];
    self.stockLabel = stockLabel;
    if ([DRTool showDiscountPriceWithGoodModel:self.goodModel]) {
        stockLabel.text = [NSString stringWithFormat:@"库存%d", [self.goodModel.activityStock intValue]];
    }else
    {
        stockLabel.text = [NSString stringWithFormat:@"库存%d", [self.goodModel.plusCount intValue]];
    }
    stockLabel.textColor = DRBlackTextColor;
    stockLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize stockLabelSize = [stockLabel.text sizeWithLabelFont:stockLabel.font];
    stockLabel.frame = CGRectMake(self.goodPriceLabel.x, CGRectGetMaxY(self.goodPriceLabel.frame) + 7, stockLabelSize.width, stockLabelSize.height);
    [self addSubview:stockLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 85, self.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    UIView * line = line1;
    if ([self.goodModel.sellType intValue] == 2) {
        //购买数量
        UILabel * numberLabel = [[UILabel alloc] init];
        numberLabel.text = @"购买数量";
        numberLabel.textColor = DRBlackTextColor;
        numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        CGSize numberLabelSize = [numberLabel.text sizeWithLabelFont:numberLabel.font];
        CGFloat goodPriceLabelY = CGRectGetMaxY(line1.frame) + 23;
        numberLabel.frame = CGRectMake(DRMargin, goodPriceLabelY, numberLabelSize.width, numberLabelSize.height);
        [self addSubview:numberLabel];
        
        //购买数量按钮
        CGFloat numberButtonW = 52;
        CGFloat numberButtonH = 26;
        CGFloat numberButtonY = CGRectGetMaxY(numberLabel.frame) + 12;
        NSMutableArray *numberButtonTitles = [NSMutableArray array];
        for (NSDictionary * wholesaleRuleDic in _goodModel.wholesaleRule) {
            NSString * countStr = [NSString stringWithFormat:@"%@", wholesaleRuleDic[@"count"]];
            [numberButtonTitles addObject:countStr];
        }
        UIView * lastNumberButton;
        for (int i = 0; i < numberButtonTitles.count; i++) {
            UIButton * numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
            numberButton.frame = CGRectMake(DRMargin + (numberButtonW + 15) * i, numberButtonY, numberButtonW, numberButtonH);
            numberButton.adjustsImageWhenHighlighted = NO;
            [numberButton setBackgroundImage:[UIImage ImageFromColor:DRColor(240, 240, 240, 1) WithRect:numberButton.bounds] forState:UIControlStateNormal];
            [numberButton setBackgroundImage:[UIImage ImageFromColor:DRDefaultColor WithRect:numberButton.bounds] forState:UIControlStateSelected];
            [numberButton setBackgroundImage:[UIImage ImageFromColor:DRDefaultColor WithRect:numberButton.bounds] forState:UIControlStateHighlighted];
            [numberButton setTitle:numberButtonTitles[i] forState:UIControlStateNormal];
            numberButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
            [numberButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            [numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [numberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            numberButton.layer.masksToBounds = YES;
            numberButton.layer.cornerRadius = 10;
            [numberButton addTarget:self action:@selector(numberButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:numberButton];
            lastNumberButton = numberButton;
        }
        
        //分割线
        UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lastNumberButton.frame) + 12, self.width, 1)];
        line2.backgroundColor = DRWhiteLineColor;
        [self addSubview:line2];
        line = line2;
    }
    
    //其他数量
    UILabel * otherNumberLabel = [[UILabel alloc] init];
    if ([self.goodModel.sellType intValue] == 2) {
        otherNumberLabel.text = @"其他数量";
    }else
    {
        otherNumberLabel.text = @"购买数量";
    }
    otherNumberLabel.textColor = DRBlackTextColor;
    otherNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize otherNumberLabelSize = [otherNumberLabel.text sizeWithLabelFont:otherNumberLabel.font];
    CGFloat otherNumberLabelY = CGRectGetMaxY(line.frame) + (57 - otherNumberLabelSize.height) / 2;
    otherNumberLabel.frame = CGRectMake(DRMargin, otherNumberLabelY, otherNumberLabelSize.width, otherNumberLabelSize.height);
    [self addSubview:otherNumberLabel];
    
    //改变数量
    DRAdjustNumberView * numberView = [[DRAdjustNumberView alloc] init];
    self.numberView = numberView;
    CGFloat numberViewW = 90;
    CGFloat numberViewH = 27;
    CGFloat numberViewX = self.width - DRMargin - numberViewW;
    CGFloat numberViewY = CGRectGetMaxY(line.frame) + (57 - numberViewH) / 2;
    numberView.frame = CGRectMake(numberViewX, numberViewY, numberViewW, numberViewH);
    numberView.delegate = self;
    numberView.textField.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    //plusCount
    numberView.max = [self.goodModel.plusCount intValue];//最大
    numberView.min = minCount;
    numberView.textField.placeholder = [NSString stringWithFormat:@"%d",minCount];
    if ([self.goodModel.sellType intValue] == 1) {
        numberView.textField.text = @"1";
    }
        
    [self addSubview:numberView];
    
    //分割线
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame) + 57, self.width, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [self addSubview:line3];
    
    //确定
    if ([self.goodModel.sellType intValue] == 1) {//一物一拍/零售
        UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = CGRectMake(0, self.height - 45, self.width, 45);
        confirmButton.backgroundColor = DRDefaultColor;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmButton];
    }else
    {
        for (int i = 0; i < 2; i++) {
            UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
            confirmButton.tag = i;
            confirmButton.frame = CGRectMake(screenWidth / 2 * i, self.height - 45, screenWidth / 2, 45);
            if (i == 0) {
                confirmButton.backgroundColor = DRColor(20, 215, 167, 1);
                [confirmButton setTitle:@"加入购物车" forState:UIControlStateNormal];
            }else
            {
                confirmButton.backgroundColor = DRDefaultColor;
                [confirmButton setTitle:@"立刻购买" forState:UIControlStateNormal];
            }
            [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
            [confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:confirmButton];
        }
    }
    
    //exit
    CGFloat exitButtonWH = 15;
    UIButton * exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(screenWidth - exitButtonWH - 10, 10, exitButtonWH, exitButtonWH);
    [exitButton setImage:[UIImage imageNamed:@"groupon_exit"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:exitButton];
}
- (void)exitButtonDidClick
{
    [self.superview removeFromSuperview];
}
- (void)adjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number
{
    self.selectedNumberButton.selected = NO;
    self.selectedNumberButton = nil;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
    NSArray *wholesaleRule = [self.goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
    
    for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
        int count = [wholesaleRuleDic[@"count"] intValue];
        if ([number intValue] >= count) {
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100.0]];
            break;
        }
    }
}
- (void)numberButtonDidClick:(UIButton *)button
{
    if (button == self.selectedNumberButton) {
        return;
    }
    self.selectedNumberButton.selected = NO;
    button.selected = YES;
    self.selectedNumberButton = button;
    self.numberView.currentNum = button.currentTitle;
    
    for (NSDictionary * wholesaleRuleDic in self.goodModel.wholesaleRule) {
        int count = [wholesaleRuleDic[@"count"] intValue];
        if (count == [button.currentTitle intValue]) {
            self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100.0]];
        }
    }
}
- (void)confirmButtonDidClick:(UIButton *)button
{
    if (!self.selectedNumberButton && [self.numberView.currentNum intValue] == 0 && [self.goodModel.sellType intValue] == 2) {
        return;
    }
    int number = 0;
    if (self.selectedNumberButton) {
        number = [self.selectedNumberButton.currentTitle intValue];
    }else{
        number = [self.numberView.currentNum intValue];
    }
    NSString *price = self.goodPriceLabel.text;
    BOOL isBuy = NO;
    if ([self.goodModel.sellType intValue] == 1) {//一物一拍/零售
        isBuy = self.isBuy;
    }else
    {
        if (button.tag == 0) {
            isBuy = NO;
        }else
        {
            isBuy = YES;
        }
    }
    price = [price stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    if (_delegate && [_delegate respondsToSelector:@selector(wholesaleNumberView:selectedNumber:price:isBuy:)]) {
        [_delegate wholesaleNumberView:self selectedNumber:number price:[price doubleValue] isBuy:isBuy];
    }

}


@end
