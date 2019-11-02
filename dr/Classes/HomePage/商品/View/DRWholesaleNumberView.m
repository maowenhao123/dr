//
//  DRWholesaleNumberView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRWholesaleNumberView.h"
#import "DRAdjustNumberView.h"

@interface DRWholesaleNumberView ()<UIGestureRecognizerDelegate, DRAdjustNumberViewDelegate>

@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UILabel * stockLabel;
@property (nonatomic,weak) UIButton *selectedNumberButton;
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, assign) int type; //0确定 1加入购物车 2立刻购买

@end

@implementation DRWholesaleNumberView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel type:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.goodModel = goodModel;
        self.type = type;
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height + [DRTool getSafeAreaBottom], screenWidth, screenHeight * 0.6)];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
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
    [contentView addSubview:goodImageView];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + 7, 14, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + 7), [UIFont systemFontOfSize:DRGetFontSize(34)].lineHeight)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRDefaultColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    int minCount = 1;
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
    [contentView addSubview:goodPriceLabel];
    
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
    [contentView addSubview:stockLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 85, self.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    //购买数量
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.text = @"购买数量";
    numberLabel.textColor = DRBlackTextColor;
    numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize numberLabelSize = [numberLabel.text sizeWithLabelFont:numberLabel.font];
    CGFloat goodPriceLabelY = CGRectGetMaxY(line1.frame) + 23;
    numberLabel.frame = CGRectMake(DRMargin, goodPriceLabelY, numberLabelSize.width, numberLabelSize.height);
    [contentView addSubview:numberLabel];
    
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
        [contentView addSubview:numberButton];
        lastNumberButton = numberButton;
    }
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lastNumberButton.frame) + 12, self.width, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line2];
    
    //其他数量
    UILabel * otherNumberLabel = [[UILabel alloc] init];
    otherNumberLabel.text = @"其他数量";
    otherNumberLabel.textColor = DRBlackTextColor;
    otherNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize otherNumberLabelSize = [otherNumberLabel.text sizeWithLabelFont:otherNumberLabel.font];
    CGFloat otherNumberLabelY = CGRectGetMaxY(line2.frame) + (57 - otherNumberLabelSize.height) / 2;
    otherNumberLabel.frame = CGRectMake(DRMargin, otherNumberLabelY, otherNumberLabelSize.width, otherNumberLabelSize.height);
    [contentView addSubview:otherNumberLabel];
    
    //改变数量
    DRAdjustNumberView * numberView = [[DRAdjustNumberView alloc] init];
    self.numberView = numberView;
    CGFloat numberViewW = 90;
    CGFloat numberViewH = 27;
    CGFloat numberViewX = self.width - DRMargin - numberViewW;
    CGFloat numberViewY = CGRectGetMaxY(line2.frame) + (57 - numberViewH) / 2;
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
        
    [contentView addSubview:numberView];
    
    //分割线
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame) + 57, self.width, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line3];
    
    //确定
    UIView * buttonView = [[UIView alloc] initWithFrame:CGRectMake(DRMargin, contentView.height - 45 - 5, screenWidth - 2 * DRMargin, 45)];
    buttonView.layer.masksToBounds = YES;
    buttonView.layer.cornerRadius = buttonView.height / 2;
    [contentView addSubview:buttonView];
    
    if (self.type == 0) {
        for (int i = 0; i < 2; i++) {
            UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
            confirmButton.tag = i;
            confirmButton.frame = CGRectMake(buttonView.width / 2 * i, 0, buttonView.width / 2, buttonView.height);
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
            [buttonView addSubview:confirmButton];
        }
    }else
    {
        UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = buttonView.bounds;
        confirmButton.backgroundColor = DRDefaultColor;
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:confirmButton];
    }
    
    //exit
    CGFloat exitButtonWH = 15;
    UIButton * exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame = CGRectMake(screenWidth - exitButtonWH - 10, 10, exitButtonWH, exitButtonWH);
    [exitButton setImage:[UIImage imageNamed:@"groupon_exit"] forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:exitButton];
    
    //动画
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        contentView.y = self.height - contentView.height;
    }];
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
    BOOL isBuy = button.tag == 1;
    if (self.type == 1) {
        isBuy = NO;
    }else if (self.type == 2)
    {
        isBuy = YES;
    }
    price = [price stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    if (_delegate && [_delegate respondsToSelector:@selector(goodSelectedNumber:price:isBuy:specificationModel:)]) {
        [_delegate goodSelectedNumber:number price:[price doubleValue] isBuy:isBuy specificationModel:nil];
    }
    
    [self removeFromSuperview];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (CGRectContainsPoint(self.contentView.frame, [touch locationInView:self.contentView.superview])) {
            return NO;
        }
    }
    return YES;
}


@end
