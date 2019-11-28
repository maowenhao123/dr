//
//  DRSingleSpecificationView.m
//  dr
//
//  Created by dahe on 2019/8/6.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRSingleSpecificationView.h"
#import "DRAdjustNumberView.h"
#import "XLPhotoBrowser.h"

@interface DRSingleSpecificationView ()<UIGestureRecognizerDelegate, DRAdjustNumberViewDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

@property (nonatomic,weak) UIView * contentView;
@property (nonatomic,weak) UIImageView * goodImageView;
@property (nonatomic,weak) UILabel * goodPriceLabel;
@property (nonatomic,weak) UILabel * stockLabel;
@property (nonatomic,weak) UIButton *selectedSpecificationButton;
@property (nonatomic,weak) UIImageView * specificationImageView;
@property (nonatomic,weak) UILabel * specificationNameLabel;
@property (nonatomic, weak) DRAdjustNumberView * numberView;//数量改变
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, assign) int type; //0确定 1加入购物车 2立刻购买

@end

@implementation DRSingleSpecificationView

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
    goodImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    goodImageView.layer.borderWidth = 2;
    goodImageView.layer.masksToBounds = YES;
    goodImageView.layer.cornerRadius = 4;
    goodImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap)];
    [goodImageView addGestureRecognizer:imageTap];
    [contentView addSubview:goodImageView];
    
    //商品价格
    UILabel * goodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(goodImageView.frame) + 7, 14, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + 7), [UIFont systemFontOfSize:DRGetFontSize(34)].lineHeight)];
    self.goodPriceLabel = goodPriceLabel;
    goodPriceLabel.textColor = DRDefaultColor;
    goodPriceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(34)];
    [contentView addSubview:goodPriceLabel];

    //库存
    UILabel * stockLabel = [[UILabel alloc] init];
    self.stockLabel = stockLabel;
    stockLabel.textColor = DRBlackTextColor;
    stockLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    stockLabel.frame = CGRectMake(self.goodPriceLabel.x, CGRectGetMaxY(self.goodPriceLabel.frame) + 7, screenWidth - DRMargin - (CGRectGetMaxX(goodImageView.frame) + 7), [UIFont systemFontOfSize:DRGetFontSize(24)].lineHeight);
    [contentView addSubview:stockLabel];
    
    //scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 85, screenWidth, contentView.height - 85 - 45 - 5)];
    scrollView.showsVerticalScrollIndicator = NO;
    [contentView addSubview:scrollView];
    
    UIView * lastView = nil;
    if (_goodModel.specifications.count > 0) {
        //分割线
        UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 85, self.width, 1)];
        line1.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line1];
        
        for (int i = 0; i < _goodModel.specifications.count; i++) {
            DRGoodSpecificationModel * specificationModel = _goodModel.specifications[i];
            UIButton * specificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            specificationButton.tag = i;
            specificationButton.backgroundColor = DRWhiteLineColor;
            CGFloat x = CGRectGetMaxX(lastView.frame) + 20;
            CGFloat y = lastView.y;
            if (!lastView) {
                y = 15;
            }
            CGFloat textW = [specificationModel.name sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(28)]].width;
            CGFloat w = textW + 25 + 10 + 2 * 15;
            if (x + w + 20 > screenWidth) {
                x = 20;
                y = CGRectGetMaxY(lastView.frame) + 15;
            }
            specificationButton.frame = CGRectMake(x, y, w, 38);
            specificationButton.layer.masksToBounds = YES;
            specificationButton.layer.cornerRadius = 4;
            specificationButton.layer.borderColor = DRDefaultColor.CGColor;
            [specificationButton addTarget:self action:@selector(specificationButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:specificationButton];
            lastView = specificationButton;
            
            UIImageView * specificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (40 - 25) / 2, 25, 25)];
            self.specificationImageView = specificationImageView;
            specificationImageView.contentMode = UIViewContentModeScaleAspectFill;
            specificationImageView.layer.masksToBounds = YES;
            NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, specificationModel.picUrl,smallPicUrl];
            [specificationImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            [specificationButton addSubview:specificationImageView];
            
            UILabel * specificationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(specificationImageView.frame) + 10, 0, textW, 40)];
            self.specificationNameLabel = specificationNameLabel;
            specificationNameLabel.text = specificationModel.name;
            specificationNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
            if ([specificationModel.storeCount intValue] == 0) {
                specificationButton.enabled = NO;
                specificationNameLabel.textColor = DRGrayLineColor;
            }else
            {
                specificationButton.enabled = YES;
                specificationNameLabel.textColor = DRBlackTextColor;
            }
            [specificationButton addSubview:specificationNameLabel];
            
            if ([specificationModel.storeCount intValue] > 0) {
                if (!self.selectedSpecificationButton) {
                    self.selectedSpecificationButton = specificationButton;
                    specificationButton.selected = YES;
                    specificationButton.layer.borderWidth = 1;
                    
                    stockLabel.text = [NSString stringWithFormat:@"库存%@", specificationModel.storeCount];
                    goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[specificationModel.price doubleValue] / 100]];
                    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, specificationModel.picUrl, smallPicUrl];
                    [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    specificationNameLabel.textColor = DRDefaultColor;
                }
            }
        }
    }else
    {
        NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,self.goodModel.spreadPics,smallPicUrl];
        [goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        goodPriceLabel.text =[NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[self.goodModel.price doubleValue] / 100]];
        stockLabel.text = [NSString stringWithFormat:@"库存%@", self.goodModel.plusCount];
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
    numberView.textField.placeholder = [NSString stringWithFormat:@"%d", 1];
    numberView.textField.text = @"1";
    [scrollView addSubview:numberView];
    
    if (self.goodModel.specifications.count > 0) {
        //plusCount
        DRGoodSpecificationModel * specificationModel = _goodModel.specifications[0];
        numberView.max = [specificationModel.storeCount intValue];//最大
        numberView.min = 1;
    }else
    {
        numberView.max = [self.goodModel.plusCount intValue];//最大
        numberView.min = 1;
    }
    //分割线
    UIView * line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame) + 57, self.width, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [scrollView addSubview:line3];
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(line3.frame) + 100);
    
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

- (void)specificationButtonDidClick:(UIButton *)button
{
    if (self.selectedSpecificationButton == button) {
        return;
    }
    
    for (UIView * subView in self.selectedSpecificationButton.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *specificationNameLabel = (UILabel *)subView;
            specificationNameLabel.textColor = DRBlackTextColor;
        }
    }
    DRGoodSpecificationModel * specificationModel = _goodModel.specifications[button.tag];
    for (UIView * subView in button.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *specificationNameLabel = (UILabel *)subView;
            if ([specificationModel.storeCount intValue] > 0) {
                specificationNameLabel.textColor = DRDefaultColor;
            }else
            {
                specificationNameLabel.textColor = DRGrayLineColor;
            }
        }
    }
    
    self.selectedSpecificationButton.selected = NO;
    self.selectedSpecificationButton.layer.borderWidth = 0;
    button.selected = YES;
    button.layer.borderWidth = 1;
    self.selectedSpecificationButton = button;
    
    self.stockLabel.text = [NSString stringWithFormat:@"库存%@", specificationModel.storeCount];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:[specificationModel.price doubleValue] / 100]];
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, specificationModel.picUrl, smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.numberView.max = [specificationModel.storeCount intValue];
}

- (void)imageDidTap
{
    XLPhotoBrowser * photoBrowser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:0 imageCount:1 datasource:self];
    photoBrowser.delegate = self;
    photoBrowser.browserStyle = XLPhotoBrowserStyleSimple;
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
    if (DRArrayIsEmpty(_goodModel.specifications)) {
        if (_delegate && [_delegate respondsToSelector:@selector(goodSelectedNumber:price:isBuy:specificationModel:)]) {
            [_delegate goodSelectedNumber:number price:[price doubleValue] isBuy:isBuy specificationModel:nil];
        }
    }else
    {
        DRGoodSpecificationModel * specificationModel = _goodModel.specifications[self.selectedSpecificationButton.tag];
        if (_delegate && [_delegate respondsToSelector:@selector(goodSelectedNumber:price:isBuy:specificationModel:)]) {
            [_delegate goodSelectedNumber:number price:[price doubleValue] isBuy:isBuy specificationModel:specificationModel];
        }
    }
    
    [self removeFromSuperview];
}

#pragma mark - XLPhotoBrowserDelegate
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    DRGoodSpecificationModel * specificationModel = _goodModel.specifications[self.selectedSpecificationButton.tag];
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl, specificationModel.picUrl, smallPicUrl];
    return [NSURL URLWithString:imageUrlStr];
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
