//
//  DROrderGroupTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

@interface DROrderGroupTableViewCell : UITableViewCell

+ (DROrderGroupTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DROrderModel *orderModel;

@end
