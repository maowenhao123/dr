//
//  DRAdjustNumberView.h
//  dr
//
//  Created by apple on 2017/3/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRAdjustNumberView;

@protocol DRAdjustNumberViewDelegate <NSObject>

@optional
- (void)adjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number;
- (void)decreaseNumberAdjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number;
- (void)increaseNumberAdjustNumbeView:(DRAdjustNumberView *)numberView currentNumber:(NSString *)number;

@end

@interface DRAdjustNumberView : UIView


/**
 *  边框颜色，默认值是浅灰色
 */
@property (nonatomic, assign) UIColor *lineColor;

/**
 *  文本框内容
 */
@property (nonatomic, copy) NSString *currentNum;

/**
 *  输入框
 */
@property (nonatomic, weak) UITextField *textField;
/**
 *  最大值
 */
@property (nonatomic, assign) NSInteger max;
/**
 *  最小值
 */
@property (nonatomic, assign) NSInteger min;

/**
 协议
 */
@property (nonatomic, weak) id <DRAdjustNumberViewDelegate> delegate;

@end
