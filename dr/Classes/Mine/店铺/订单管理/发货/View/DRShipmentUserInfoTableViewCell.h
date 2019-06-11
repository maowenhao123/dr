//
//  DRShipmentUserInfoTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShipmentGroupon.h"

@interface DRShipmentUserInfoTableViewCell : UITableViewCell

+ (DRShipmentUserInfoTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRShipmentGroupon *shipmentGroupon;

@property (nonatomic, weak) UIView *promptView;

@end
