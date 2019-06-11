//
//  DRGoodShelfTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRGoodShelfTableViewCell;
@protocol GoodShelfTableViewCellDelegate <NSObject>

- (void)goodShelfTableViewCell:(DRGoodShelfTableViewCell *)cell buttonDidClick:(UIButton *)button;

@end

@interface DRGoodShelfTableViewCell : UITableViewCell

+ (DRGoodShelfTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRGoodModel *model;

/**
 协议
 */
@property (nonatomic, weak) id <GoodShelfTableViewCellDelegate> delegate;

@property (nonatomic,weak) UIView *bottomView;

@end
