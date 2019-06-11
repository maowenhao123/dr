//
//  DRCommentOrderTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRCommentGoodModel.h"

@class DRCommentOrderTableViewCell;
@protocol CommentOrderTableViewCellDelegate <NSObject>

- (void)commentOrderTableViewCell:(DRCommentOrderTableViewCell *)cell commentButtonDidClick:(UIButton *)button;

@end

@interface DRCommentOrderTableViewCell : UITableViewCell

+ (DRCommentOrderTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UIView * line;

/**
 协议
 */
@property (nonatomic, weak) id <CommentOrderTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRCommentGoodModel *commentGoodModel;

@end
