//
//  DRMessageChooseGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/12/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DRMessageChooseGoodModel.h"

@class DRMessageChooseGoodTableViewCell;
@protocol MessageChooseGoodTableViewCellDelegate <NSObject>

- (void)upDataGoodTableViewCell:(DRMessageChooseGoodTableViewCell *)cell isSelected:(BOOL)isSelected;

@end


@interface DRMessageChooseGoodTableViewCell : UITableViewCell

+ (DRMessageChooseGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 数据
 */
@property (nonatomic, strong) DRMessageChooseGoodModel *model;

/**
 协议
 */
@property (nonatomic, weak) id <MessageChooseGoodTableViewCellDelegate> delegate;

@property (nonatomic, weak) UILabel *goodPriceLabel;//商品价格

@end
