//
//  DRGoodScreeningView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/12.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRGoodScreeningView;
@protocol GoodScreeningViewDelegate <NSObject>

- (void)goodScreeningView:(DRGoodScreeningView *)goodScreeningView confirmButtonDidClick:(UIButton *)button;

@end

@interface DRGoodScreeningView : UIView

@property (nonatomic, copy) NSString *categoryId;//分类Id,无此参数，查询全部
@property (nonatomic,copy) NSString *sellType;
@property (nonatomic, copy) NSString *isGroup;
@property (nonatomic, copy) NSString *minPrice;
@property (nonatomic, copy) NSString *maxPrice;

/**
 协议
 */
@property (nonatomic, weak) id <GoodScreeningViewDelegate> delegate;

@end
