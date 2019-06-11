//
//  DRGrouponTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGrouponModel.h"

@class DRGrouponTableViewCell;
@protocol GrouponTableViewCellDelegate <NSObject>

- (void)grouponTableViewCell:(DRGrouponTableViewCell *)cell joinGrouponButtonDidClick:(UIButton *)button;

@end

@interface DRGrouponTableViewCell : UITableViewCell

+ (DRGrouponTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRGrouponModel *model;

/**
 协议
 */
@property (nonatomic, weak) id <GrouponTableViewCellDelegate> delegate;

@end
