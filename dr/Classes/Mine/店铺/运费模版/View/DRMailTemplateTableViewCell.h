//
//  DRMailTemplateTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRMailTemplateModel.h"

@class DRMailTemplateTableViewCell;
@protocol MailTemplateTableViewCellDelegate <NSObject>

- (void)mailTemplateTableViewCellDeleteButtonDidClickWithCell:(DRMailTemplateTableViewCell *)cell;
- (void)mailTemplateTableViewCellEditButtonDidClickWithCell:(DRMailTemplateTableViewCell *)cell;

@end

@interface DRMailTemplateTableViewCell : UITableViewCell

+ (DRMailTemplateTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) id <MailTemplateTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRMailTemplateModel *mailTemplateModel;

@property (nonatomic,weak) UIView *bottomView;

@end
