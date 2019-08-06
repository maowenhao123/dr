//
//  DRStartGrouponView.m
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRStartGrouponView.h"
#import "DRAdjustNumberView.h"

@interface DRStartGrouponView ()<UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UILabel * stockLabel;
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, assign) int successCount;

@end

@implementation DRStartGrouponView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel successCount:(int)successCount
{
    self = [super initWithFrame:frame];
    if (self) {
        self.goodModel = goodModel;
        self.successCount = successCount;
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
    goodImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    goodImageView.layer.borderWidth = 2;
    goodImageView.layer.masksToBounds = YES;
    goodImageView.layer.cornerRadius = 4;
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,self.goodModel.spreadPics,smallPicUrl];
    [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [contentView addSubview:goodImageView];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] init];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.goodModel.groupPrice doubleValue] / 100]];
    goodPriceLabel.textColor = DRDefaultColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    CGSize goodPriceLabelSize = [goodPriceLabel.text sizeWithLabelFont:goodPriceLabel.font];
    goodPriceLabel.frame = CGRectMake(CGRectGetMaxX(goodImageView.frame) + 7, 14, goodPriceLabelSize.width, goodPriceLabelSize.height);
    [contentView addSubview:goodPriceLabel];
    
    //plusCount
    //库存
    UILabel * stockLabel = [[UILabel alloc] init];
    self.stockLabel = stockLabel;
    stockLabel.text = [NSString stringWithFormat:@"库存%d", [self.goodModel.plusCount intValue]];
    stockLabel.textColor = DRBlackTextColor;
    stockLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize stockLabelSize = [stockLabel.text sizeWithLabelFont:stockLabel.font];
    stockLabel.frame = CGRectMake(self.goodPriceLabel.x, CGRectGetMaxY(self.goodPriceLabel.frame) + 7, stockLabelSize.width, stockLabelSize.height);
    [contentView addSubview:stockLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 85, self.width, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    //成团数量
    UILabel * grouponLabel =  [[UILabel alloc] init];
    grouponLabel.text = @"成团数量";
    grouponLabel.textColor = DRBlackTextColor;
    grouponLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize grouponLabelSize = [grouponLabel.text sizeWithLabelFont:grouponLabel.font];
    CGFloat grouponLabelY = CGRectGetMaxY(line1.frame) + 20;
    grouponLabel.frame = CGRectMake(DRMargin, grouponLabelY, grouponLabelSize.width, grouponLabelSize.height);
    [contentView addSubview:grouponLabel];
    
    UILabel * grouponNumberLabel =  [[UILabel alloc] init];
    grouponNumberLabel.text = [NSString stringWithFormat:@"%d", self.successCount];
    grouponNumberLabel.textColor = DRBlackTextColor;
    grouponNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize grouponNumberLabelSize = [grouponNumberLabel.text sizeWithLabelFont:grouponNumberLabel.font];
    grouponNumberLabel.frame = CGRectMake(self.width - DRMargin - grouponNumberLabelSize.width, grouponLabelY, grouponNumberLabelSize.width, grouponNumberLabelSize.height);
    [contentView addSubview:grouponNumberLabel];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(grouponLabel.frame) + 20, self.width, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line2];
    
    //其他数量
    UILabel * numberLabel = [[UILabel alloc] init];
    numberLabel.text = @"购买数量";
    numberLabel.textColor = DRBlackTextColor;
    numberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    CGSize numberLabelSize = [numberLabel.text sizeWithLabelFont:numberLabel.font];
    CGFloat numberLabelY = CGRectGetMaxY(line2.frame) + (57 - numberLabelSize.height) / 2;
    numberLabel.frame = CGRectMake(DRMargin, numberLabelY, numberLabelSize.width, numberLabelSize.height);
    [contentView addSubview:numberLabel];
    
    //改变数量
    DRAdjustNumberView * numberView = [[DRAdjustNumberView alloc] init];
    self.numberView = numberView;
    CGFloat numberViewW = 90;
    CGFloat numberViewH = 27;
    CGFloat numberViewX = self.width - DRMargin - numberViewW;
    CGFloat numberViewY = CGRectGetMaxY(line2.frame) + (57 - numberViewH) / 2;
    numberView.frame = CGRectMake(numberViewX, numberViewY, numberViewW, numberViewH);
    numberView.textField.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    numberView.textField.text = @"1";
    numberView.max = 999;//最大999
    [contentView addSubview:numberView];
    
    //分割线
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame) + 57, self.width, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line3];

    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(0, contentView.height - 45, self.width, 45);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"立刻开团" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
    
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

- (void)confirmButtonDidClick
{
    int minCount = 0;
    for (NSDictionary * wholesaleRuleDic in self.goodModel.wholesaleRule) {
        NSInteger index = [self.goodModel.wholesaleRule indexOfObject:wholesaleRuleDic];
        int count = [wholesaleRuleDic[@"count"] intValue];
        if (index == 0) {
            minCount = count;
        }else
        {
            minCount = count < minCount ? count : minCount;
        }
    }
    
    //plusCount
    if ([self.numberView.currentNum intValue] > (minCount + [self.goodModel.plusCount intValue])) {
        [MBProgressHUD showError:@"购买数量不能大于剩余数量"];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(startGrouponView:selectedNumber:price:)]) {
        [_delegate startGrouponView:self selectedNumber:[self.numberView.currentNum intValue] price:[self.goodModel.groupPrice doubleValue] / 100];
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
