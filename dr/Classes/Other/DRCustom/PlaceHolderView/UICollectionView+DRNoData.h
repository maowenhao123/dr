//
//  UICollectionView+DRNoData.h
//  dr
//
//  Created by 毛文豪 on 2017/7/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (DRNoData)

- (void)showNoDataWithTitle:(NSString *)title description:(NSString *)description rowCount:(NSInteger)rowCount;

@end
