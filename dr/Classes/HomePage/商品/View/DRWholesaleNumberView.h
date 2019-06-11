//
//  DRWholesaleNumberView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRWholesaleNumberView;
@protocol WholesaleNumberViewDelegate <NSObject>

- (void)wholesaleNumberView:(DRWholesaleNumberView *)wholesaleNumberView selectedNumber:(int)number price:(float)price isBuy:(BOOL)isBuy;

@end

@interface DRWholesaleNumberView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel isBuy:(BOOL)isBuy;

/**
 协议
 */
@property (nonatomic, weak) id <WholesaleNumberViewDelegate> delegate;

@end
