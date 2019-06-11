//
//  DRTitleCycleScrollView.h
//  dr
//
//  Created by 毛文豪 on 2018/12/18.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRTitleCycleScrollView : UIView
/**
 *  初始化
 *
 *  @param frame             frame
 *  @param titleArray        滚动的标题数组
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray animationDuration:(NSTimeInterval)animationDuration;
/**
 滚动的标题数组
 **/
@property (nonatomic, strong) NSArray *titleArray;
/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

@end
