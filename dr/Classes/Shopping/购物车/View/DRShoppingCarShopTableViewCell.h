//
//  DRShoppingCarShopTableViewCell.h
//  dr
//
//  Created by apple on 2017/3/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShoppingCarShopModel.h"

@class DRShoppingCarShopTableViewCell;

@protocol ShoppingCarShopTableViewCellDelegate <NSObject>

- (void)upDataShopTableViewCell:(DRShoppingCarShopTableViewCell *)cell isSelected:(BOOL)isSelected;

@end

@interface DRShoppingCarShopTableViewCell : UITableViewCell

+ (DRShoppingCarShopTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 数据
 */
@property (nonatomic, strong) DRShoppingCarShopModel * model;
/**
 协议
 */
@property (nonatomic, weak) id <ShoppingCarShopTableViewCellDelegate> delegate;


@end
