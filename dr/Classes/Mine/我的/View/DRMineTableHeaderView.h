//
//  DRMineTableHeaderView.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DRMineTableHeaderViewDelegate <NSObject>

- (void)headerViewDidClickUserInfo;//点击用户信息的代理方法
- (void)headerViewSettingButtonDidClickUserInfo;//点击用户信息的代理方法
- (void)headerViewDidClickRechargeButton:(UIButton *)button;//点击提现和充值的代理方法

@end

@interface DRMineTableHeaderView : UIView

@property (nonatomic, weak) id<DRMineTableHeaderViewDelegate> delegate;

- (void)reloadData;

@end
