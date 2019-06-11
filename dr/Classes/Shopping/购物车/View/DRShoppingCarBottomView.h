//
//  DRShoppingBottomView.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRShoppingCarBottomView;
@protocol ShoppingCarBottomViewDelegate <NSObject>

- (void)bottomView:(DRShoppingCarBottomView *)bottomView allSelectedButtonDidClick:(UIButton *)button;
- (void)bottomView:(DRShoppingCarBottomView *)bottomView confirmButtonDidClick:(UIButton *)button;
- (void)bottomView:(DRShoppingCarBottomView *)bottomView deleteButtonDidClick:(UIButton *)button;

@end

@interface DRShoppingCarBottomView : UIView

@property (nonatomic, weak) UIButton * allSelectedButton;//全选按钮
@property (nonatomic, weak) UILabel *moneyLabel;//金额
@property (nonatomic, weak) UIButton *confirmButton;//确认按钮
@property (nonatomic, assign) id <ShoppingCarBottomViewDelegate> delegate;

//更新数据
- (void)updataWithData:(NSArray *)dataArray isEdit:(BOOL)isEdit;

@end
