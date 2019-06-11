//
//  DRChooseSeckillGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DRChooseSeckillGoodTableViewCell;
@protocol ChooseSeckillGoodTableViewCellDelegate <NSObject>

- (void)chooseSeckillGoodTableViewCell:(DRChooseSeckillGoodTableViewCell *)cell buttonDidClick:(UIButton *)button;

@end

@interface DRChooseSeckillGoodTableViewCell : UITableViewCell

+ (DRChooseSeckillGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 协议
 */
@property (nonatomic, weak) id <ChooseSeckillGoodTableViewCellDelegate> delegate;

@property (nonatomic, strong) DRGoodModel *goodModel;

@end

NS_ASSUME_NONNULL_END
