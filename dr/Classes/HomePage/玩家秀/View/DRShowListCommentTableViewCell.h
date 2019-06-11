//
//  DRShowListCommentTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowCommentModel.h"

@interface DRShowListCommentTableViewCell : UITableViewCell

+ (DRShowListCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRShowCommentModel * model;

@end
