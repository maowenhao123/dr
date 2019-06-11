//
//  DRReturnGoodTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRReturnGoodModel.h"

@class DRReturnGoodTableViewCell;
@protocol ReturnGoodTableViewCellDelegate <NSObject>

- (void)returnGoodTableViewCell:(DRReturnGoodTableViewCell *)cell returnGoodButtonDidClick:(UIButton *)button;

@end

@interface DRReturnGoodTableViewCell : UITableViewCell

+ (DRReturnGoodTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UIView * line;

/**
 协议
 */
@property (nonatomic, weak) id <ReturnGoodTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRReturnGoodModel *returnGoodModel;

@end
