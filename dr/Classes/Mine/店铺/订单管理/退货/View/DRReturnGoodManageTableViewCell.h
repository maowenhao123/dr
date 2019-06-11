//
//  DRReturnGoodManageTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReturnGoodModel.h"

@class DRReturnGoodManageTableViewCell;
@protocol ReturnGoodManageTableViewCellDelegate <NSObject>

- (void)returnGoodManageTableViewCell:(DRReturnGoodManageTableViewCell *)cell buttonDidClick:(UIButton *)button;

@end

@interface DRReturnGoodManageTableViewCell : UITableViewCell

+ (DRReturnGoodManageTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UIView * line;

@property (nonatomic,strong) DRReturnGoodModel * returnGoodModel;

@property (nonatomic, assign) id <ReturnGoodManageTableViewCellDelegate> delegate;

@end
