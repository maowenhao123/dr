//
//  DRReturnGoodOrderTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRCommentGoodModel.h"

@class DRReturnGoodOrderTableViewCell;
@protocol ReturnGoodOrderTableViewCellDelegate <NSObject>

- (void)returnGoodOrderTableViewCell:(DRReturnGoodOrderTableViewCell *)cell returnGoodButtonDidClick:(UIButton *)button;

@end

@interface DRReturnGoodOrderTableViewCell : UITableViewCell

+ (DRReturnGoodOrderTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UIView * line;

/**
 协议
 */
@property (nonatomic, weak) id <ReturnGoodOrderTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRCommentGoodModel *commentGoodModel;

@end
