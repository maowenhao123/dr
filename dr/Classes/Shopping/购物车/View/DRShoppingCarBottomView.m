//
//  DRShoppingBottomView.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShoppingCarBottomView.h"
#import "DRShoppingCarShopModel.h"
#import "UIButton+DR.h"

@implementation DRShoppingCarBottomView

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
    //上分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //全选
    UIButton * allSelectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allSelectedButton = allSelectedButton;
    allSelectedButton.frame = CGRectMake(DRMargin, 0, 60, self.height);
    [allSelectedButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [allSelectedButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [allSelectedButton setTitle:@"全选" forState:UIControlStateNormal];
    [allSelectedButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    allSelectedButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [allSelectedButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:7];
    [allSelectedButton addTarget:self action:@selector(allSelectedButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:allSelectedButton];
    
    //金额和数量
    UILabel *moneyLabel = [[UILabel alloc] init];
    self.moneyLabel = moneyLabel;
    moneyLabel.textColor = DRBlackTextColor;
    moneyLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:moneyLabel];
    
    //确认按钮
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton = confirmButton;
    confirmButton.frame = CGRectMake(screenWidth - 90, 0, 90, self.height);
    confirmButton.backgroundColor = [UIColor lightGrayColor];
    confirmButton.enabled = NO;
    [confirmButton setTitle:@"去结算" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmButton];
}

- (void)allSelectedButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(bottomView:allSelectedButtonDidClick:)]) {
        [_delegate bottomView:self allSelectedButtonDidClick:button];
    }
}
- (void)confirmButtonDidClick:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"去结算"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomView:confirmButtonDidClick:)]) {
            [_delegate bottomView:self confirmButtonDidClick:button];
        }
    }else if ([button.currentTitle rangeOfString:@"删除"].location != NSNotFound)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(bottomView:deleteButtonDidClick:)]) {
            [_delegate bottomView:self deleteButtonDidClick:button];
            
            [self.confirmButton setTitle:[NSString stringWithFormat:@"删除"] forState:UIControlStateNormal];
        }
    }
}

- (void)updataWithData:(NSArray *)dataArray isEdit:(BOOL)isEdit
{
    int selectedCount = 0;//选中商品的数量
    double totalPrice = 0;//总价钱
    for (DRShoppingCarShopModel * carShopModel in dataArray) {
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (carGoodModel.isSelected) {
                selectedCount += carGoodModel.count;
                if ([DRTool showDiscountPriceWithGoodModel:carGoodModel.goodModel]) {
                    totalPrice += [carGoodModel.goodModel.discountPrice doubleValue] / 100 * carGoodModel.count;
                }else if (!DRObjectIsEmpty(carGoodModel.specificationModel))
                {
                    totalPrice += [carGoodModel.specificationModel.price doubleValue] / 100 * carGoodModel.count;
                }else
                {
                    totalPrice += [carGoodModel.goodModel.price doubleValue] / 100 * carGoodModel.count;
                }
            }
        }
    }
    
    self.moneyLabel.text = [NSString stringWithFormat:@"合计：¥%@", [DRTool formatFloat:totalPrice]];
    CGSize moneyLabelSize = [self.moneyLabel.text sizeWithLabelFont:self.moneyLabel.font];
    self.moneyLabel.frame = CGRectMake(self.width - self.confirmButton.width - 10 - moneyLabelSize.width, 0, moneyLabelSize.width, self.height);
    
    if (isEdit) {
        self.moneyLabel.hidden = YES;
        if (selectedCount == 0) {
            self.confirmButton.backgroundColor = [UIColor lightGrayColor];
            self.confirmButton.enabled = NO;
            [self.confirmButton setTitle:@"删除" forState:UIControlStateNormal];
        }else
        {
            self.confirmButton.backgroundColor = DRDefaultColor;
            self.confirmButton.enabled = YES;
            [self.confirmButton setTitle:[NSString stringWithFormat:@"删除(%d)",selectedCount] forState:UIControlStateNormal];
        }
    }else
    {
        if (totalPrice == 0) {
            self.moneyLabel.hidden = YES;
            self.confirmButton.backgroundColor = [UIColor lightGrayColor];
            self.confirmButton.enabled = NO;
        }else
        {
            self.moneyLabel.hidden = NO;
            self.confirmButton.backgroundColor = DRDefaultColor;
            self.confirmButton.enabled = YES;
        }
        [self.confirmButton setTitle:@"去结算" forState:UIControlStateNormal];
    }
}

@end
