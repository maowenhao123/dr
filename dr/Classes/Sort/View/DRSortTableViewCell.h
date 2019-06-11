//
//  DRSortTableViewCell.h
//  dr
//
//  Created by apple on 2017/3/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRSortModel.h"

@interface DRSortTableViewCell : UITableViewCell

+ (DRSortTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRSortModel * model;
@property (nonatomic,assign) BOOL haveSelected;

@end
