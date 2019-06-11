//
//  DRShowDetailHeaderView.h
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowModel.h"

@interface DRShowDetailHeaderView : UITableViewHeaderFooterView

+ (DRShowDetailHeaderView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DRShowModel * model;

@end
