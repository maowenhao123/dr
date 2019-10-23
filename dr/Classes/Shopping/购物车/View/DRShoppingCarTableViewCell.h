//
//  DRShoppingTableViewCell.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShoppingCarGoodModel.h"

@class DRShoppingCarTableViewCell;
@protocol ShoppingCarTableViewCellDelegate <NSObject>

- (void)upDataGoodTableViewCell:(DRShoppingCarTableViewCell *)cell isSelected:(BOOL)isSelected currentNumber:(NSString *)number;

@end


@interface DRShoppingCarTableViewCell : UITableViewCell

+ (DRShoppingCarTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 数据
 */
@property (nonatomic, strong) DRShoppingCarGoodModel *model;

/**
  协议
 */
@property (nonatomic, weak) id <ShoppingCarTableViewCellDelegate> delegate;

@end
