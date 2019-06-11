//
//  DRBottomPickerView.h
//  dr
//
//  Created by 毛文豪 on 2017/4/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ChoicePickerViewBlock)(NSInteger selectedIndex);

@interface DRBottomPickerView : UIView
/**
 *  创建一个底部的pickview
 *
 *  @param dataArray  数据源
 *  @param index      当前选中的index
 */
- (instancetype)initWithArray:(NSArray *)dataArray index:(NSInteger)index;

@property (copy, nonatomic)ChoicePickerViewBlock block;

- (void)show;

@end
