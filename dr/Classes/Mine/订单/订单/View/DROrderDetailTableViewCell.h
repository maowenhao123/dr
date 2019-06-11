//
//  DROrderDetailTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/5/23.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderItemDetailModel.h"

@interface DROrderDetailTableViewCell : UITableViewCell

+ (DROrderDetailTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DROrderItemDetailModel *detailModel;

@end
