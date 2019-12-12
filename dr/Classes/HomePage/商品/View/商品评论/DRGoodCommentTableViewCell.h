//
//  DRGoodCommentTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGoodCommentModel.h"

@interface DRGoodCommentTableViewCell : UITableViewCell

+ (DRGoodCommentTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRGoodCommentModel * model;

@end
