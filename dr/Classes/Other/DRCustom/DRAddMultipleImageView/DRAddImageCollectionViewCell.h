//
//  DRAddImageCollectionViewCell.h
//  chooseImage
//
//  Created by 毛文豪 on 2017/6/22.
//  Copyright © 2017年 毛文豪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRAddImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;

- (UIView *)snapshotView;

@end
