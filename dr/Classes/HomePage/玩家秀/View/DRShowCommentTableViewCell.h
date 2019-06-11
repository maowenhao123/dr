//
//  DRShowCommentTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/3/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowCommentModel.h"

@class DRShowCommentTableViewCell;
@protocol ShowCommentTableViewCellDelegate <NSObject>

- (void)showCommentTableViewCellcommentButtonDidClickWithCell:(DRShowCommentTableViewCell *)cell;

@end

@interface DRShowCommentTableViewCell : UITableViewCell

+ (DRShowCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRShowCommentModel * model;

@property (nonatomic, weak) UIView * line;

/**
 协议
 */
@property (nonatomic, weak) id <ShowCommentTableViewCellDelegate> delegate;

@end
