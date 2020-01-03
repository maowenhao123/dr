//
//  UITableView+DRNoData.h
//  dr
//
//  Created by 毛文豪 on 2017/5/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DRNoData)

- (void)showNoDataWithTitle:(NSString *)title description:(NSString *)description rowCount:(NSInteger)rowCount offY:(CGFloat)offY;
- (void)showNoDataWithTitle:(NSString *)title description:(NSString *)description rowCount:(NSInteger)rowCount;

@end
