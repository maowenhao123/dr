//
//  DRAddMultipleImageView.h
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRAddImageCollectionViewCell.h"

@protocol AddMultipleImageViewDelegate <NSObject>

@optional
- (void)viewHeightchange;

@end

@interface DRAddMultipleImageView : UIView

@property (nonatomic,weak) UICollectionView *collectionView;

@property (nonatomic, weak) UILabel * titleLabel;

@property (nonatomic, strong) NSMutableArray * images;
@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, assign) int maxImageCount;
@property (assign, nonatomic) NSTimeInterval videoMaximumDuration;
@property (nonatomic, assign) BOOL supportVideo;

- (void)setImagesWithImageUrlStrs:(NSArray *)imageUrlStrs;

- (void)setImagesWithImage:(NSArray *)images;

- (CGFloat)getViewHeight;

@property (nonatomic, assign) id <AddMultipleImageViewDelegate> delegate;

@end
