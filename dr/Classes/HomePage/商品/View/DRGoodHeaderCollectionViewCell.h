//
//  DRGoodHeaderCollectionViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/11/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGoodHeaderFrameModel.h"

@class DRGoodHeaderCollectionViewCell;
@protocol GoodHeaderCollectionViewCellDelegate <NSObject>

- (void)goodHeaderCollectionViewPlayDidClickWithCell:(DRGoodHeaderCollectionViewCell *)cell;
- (void)goodHeaderCollectionViewSpecificationDidClickWithCell:(DRGoodHeaderCollectionViewCell *)cell;

@end

@interface DRGoodHeaderCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) DRGoodHeaderFrameModel *goodHeaderFrameModel;

@property (nonatomic, weak) UIView *barView;
@property (nonatomic, weak) UILabel * goodNameLabel;
@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格
@property (nonatomic, weak) UILabel * goodDetailLabel;
/**
 协议
 */
@property (nonatomic, weak) id <GoodHeaderCollectionViewCellDelegate> delegate;

@end
