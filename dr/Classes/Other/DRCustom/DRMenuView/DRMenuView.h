//
//  DRMenuView.h
//  dr
//
//  Created by 毛文豪 on 2017/12/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate <NSObject>

- (void)menuViewButtonDidClick:(UIButton *)button;

@end

@interface DRMenuView : UIView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray left:(BOOL)left;

@property (nonatomic, assign) id <MenuViewDelegate> delegate;

@property (nonatomic,assign) CGFloat menuViewX;

@end
