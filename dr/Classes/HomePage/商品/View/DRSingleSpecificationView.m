//
//  DRSingleSpecificationView.m
//  dr
//
//  Created by dahe on 2019/8/6.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRSingleSpecificationView.h"
#import "DRAdjustNumberView.h"
#import "UIButton+DR.h"

@interface DRSingleSpecificationView ()<UIGestureRecognizerDelegate, DRAdjustNumberViewDelegate>

@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UILabel * stockLabel;
@property (nonatomic,weak) UIButton *selectedSpecificationButton;
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, assign) int type; //0确定 1加入购物车 2立刻购买

@end

@implementation DRSingleSpecificationView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel type:(int) type
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
    [contentView addSubview:goodPriceLabel];

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
    
    //scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 85, screenWidth, contentView.height - 85 - 45)];
    scrollView.showsVerticalScrollIndicator = NO;
    [contentView addSubview:scrollView];
    
    UIView * lastView = nil;
    if (1) {
        //分割线
        UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 85, self.width, 1)];
        line1.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line1];
        
        for (int i = 0; i < 30; i++) {
            UIButton * specificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            specificationButton.backgroundColor = DRColor(240, 240, 240, 1);
            [specificationButton setImage:[UIImage ImageFromColor:DRDefaultColor WithRect:CGRectMake(0, 0, 25, 25)] forState:UIControlStateNormal];
            [specificationButton setTitle:[NSString stringWithFormat:@"规格%d", i] forState:UIControlStateNormal];
            specificationButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
            CGFloat x = CGRectGetMaxX(lastView.frame) + 20;
            CGFloat y = lastView.y;
            if (!lastView) {
                y = 15;
            }
            CGFloat w = [specificationButton.currentTitle sizeWithLabelFont:specificationButton.titleLabel.font].width + 25 + 7 + 2 * 15;
            if (x + w + 20 > screenWidth) {
                x = 20;
                y = CGRectGetMaxY(lastView.frame) + 15;
            }
            specificationButton.frame = CGRectMake(x, y, w, 40);
            [specificationButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:7];
            [specificationButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
            [specificationButton setTitleColor:DRDefaultColor forState:UIControlStateSelected];
            [specificationButton setTitleColor:DRDefaultColor forState:UIControlStateHighlighted];
            [specificationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            specificationButton.layer.masksToBounds = YES;
            specificationButton.layer.cornerRadius = 10;
            specificationButton.layer.borderColor = DRDefaultColor.CGColor;
            if (i == 0) {
                self.selectedSpecificationButton = specificationButton;
                specificationButton.selected = YES;
                specificationButton.layer.borderWidth = 1;
            }
            [specificationButton addTarget:self action:@selector(specificationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:specificationButton];
            lastView = specificationButton;
        }
    }
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lastView.frame) + 15, self.width, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [scrollView addSubview:line2];
    
    //购买数量
    UILabel * otherNumberLabel = [[UILabel alloc] init];
    otherNumberLabel.text = @"购买数量";
    otherNumberLabel.textColor = DRBlackTextColor;
    otherNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize otherNumberLabelSize = [otherNumberLabel.text sizeWithLabelFont:otherNumberLabel.font];
    CGFloat otherNumberLabelY = CGRectGetMaxY(line2.frame) + (57 - otherNumberLabelSize.height) / 2;
    otherNumberLabel.frame = CGRectMake(DRMargin, otherNumberLabelY, otherNumberLabelSize.width, otherNumberLabelSize.height);
    [scrollView addSubview:otherNumberLabel];
    
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
    numberView.min = 1;
    numberView.textField.placeholder = [NSString stringWithFormat:@"%d", 1];
    numberView.textField.text = @"1";
    [scrollView addSubview:numberView];
    
    //分割线
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame) + 57, self.width, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [scrollView addSubview:line3];
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(line3.frame) + 100);
    
    //确定
    UIView * buttonView = [[UIView alloc] initWithFrame:CGRectMake(DRMargin, contentView.height - 45, screenWidth - 2 * DRMargin, 45)];
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

- (void)specificationButtonDidClick:(UIButton *)button
{
    if (self.selectedSpecificationButton == button) {
        return;
    }
    
    self.selectedSpecificationButton.selected = NO;
    self.selectedSpecificationButton.layer.borderWidth = 0;
    button.selected = YES;
    button.layer.borderWidth = 1;
    self.selectedSpecificationButton = button;
}

- (void)adjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number
{
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

- (void)confirmButtonDidClick:(UIButton *)button
{
    int number = [self.numberView.currentNum intValue];
    NSString *price = self.goodPriceLabel.text;
    price = [price stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    BOOL isBuy = button.tag == 1;
    if (self.type == 1) {
        isBuy = NO;
    }else if (self.type == 2)
    {
        isBuy = YES;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(goodSelectedNumber:price:isBuy:)]) {
        [_delegate goodSelectedNumber:number price:[price doubleValue] isBuy:isBuy];
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
