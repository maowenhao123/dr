//
//  DRChooseGoodTableViewCell.h
//  dr
//
//  Created by dahe on 2019/11/4.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DRChooseGoodTableViewCell;
@protocol ChooseSeckillGoodTableViewCellDelegate <NSObject>

- (void)chooseSeckillGoodTableViewCell:(DRChooseGoodTableViewCell *)cell buttonDidClick:(UIButton *)button;

@end

@interface DRChooseGoodTableViewCell : UITableViewCell

+ (DRChooseGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 协议
 */
@property (nonatomic, weak) id <ChooseSeckillGoodTableViewCellDelegate> delegate;

@property (nonatomic, strong) DRGoodModel *goodModel;

@end

NS_ASSUME_NONNULL_END
