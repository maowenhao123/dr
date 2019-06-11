//
//  DRShowMultipleImageView.h
//  dr
//
//  Created by 毛文豪 on 2017/7/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowMultipleImageViewDelegate <NSObject>

@optional
- (void)imageViewDidClickWithIndex:(NSInteger)index;

@end

@interface DRShowMultipleImageView : UIView

@property (nonatomic, weak) UILabel * titleLabel;

@property (nonatomic, strong) NSMutableArray * images;

@property (nonatomic, strong) NSMutableArray * imageViews;

@property (nonatomic, weak) id <ShowMultipleImageViewDelegate> delegate;

- (void)setImagesWithImageUrlStrs:(NSArray *)imageUrlStrs;

- (CGFloat)getViewHeight;

@end
