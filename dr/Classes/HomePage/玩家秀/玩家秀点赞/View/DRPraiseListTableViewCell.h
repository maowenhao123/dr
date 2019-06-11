//
//  DRPraiseListTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/12/17.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPraiseModel.h"

@class DRPraiseListTableViewCell;
@protocol PraiseListTableViewCellDelegate <NSObject>

- (void)praiseListTableViewCellPraiseButtonDidClickWithCell:(DRPraiseListTableViewCell *)cell;

@end

@interface DRPraiseListTableViewCell : UITableViewCell

+ (DRPraiseListTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) DRPraiseModel *praiseModel;

/**
 协议
 */
@property (nonatomic, weak) id <PraiseListTableViewCellDelegate> delegate;

@end
