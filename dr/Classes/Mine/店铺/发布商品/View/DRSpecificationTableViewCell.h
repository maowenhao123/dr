//
//  DRSpecificationTableViewCell.h
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGoodSpecificationModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DRSpecificationTableViewCell;
@protocol SpecificationTableViewCellDelegate <NSObject>

- (void)specificationTableViewCell:(DRSpecificationTableViewCell *)cell editButtonDidClick:(UIButton *)button;
- (void)specificationTableViewCell:(DRSpecificationTableViewCell *)cell deleteButtonDidClick:(UIButton *)button;

@end

@interface DRSpecificationTableViewCell : UITableViewCell

+ (DRSpecificationTableViewCell *)cellWithTableView:(UITableView *)tableView;
/**
 协议
 */
@property (nonatomic, weak) id <SpecificationTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRGoodSpecificationModel *goodSpecificationModel;

@end

NS_ASSUME_NONNULL_END
