//
//  DRShipmentDetaiMultipleTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/4/6.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DROrderModel.h"

@interface DRShipmentDetaiMultipleTableViewCell : UITableViewCell

+ (DRShipmentDetaiMultipleTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DROrderModel * orderModel;

@end
