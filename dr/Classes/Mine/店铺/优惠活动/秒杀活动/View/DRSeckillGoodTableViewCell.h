//
//  DRSeckillGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRSeckillGoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DRSeckillGoodTableViewCell;
@protocol SeckillGoodTableViewCellDelegate <NSObject>

- (void)seckillGoodTableViewCell:(DRSeckillGoodTableViewCell *)cell buttonDidClick:(UIButton *)button;

@end

@interface DRSeckillGoodTableViewCell : UITableViewCell

+ (DRSeckillGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRSeckillGoodModel *seckillGoodModel;

/**
 协议
 */
@property (nonatomic, weak) id <SeckillGoodTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
