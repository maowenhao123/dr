//
//  DRGoodSearchView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRGoodSearchView;
@protocol GoodSearchViewDelegate <NSObject>

- (void)goodSearchView:(DRGoodSearchView *)goodSearchView goodDidClickWithGoodModel:(DRGoodModel *)goodModel;

@end

@interface DRGoodSearchView : UIView

@property(nonatomic, weak)id <GoodSearchViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * dataArray;
- (void)searchGoodWithKeyword:(NSString *)keyWord;

@end
