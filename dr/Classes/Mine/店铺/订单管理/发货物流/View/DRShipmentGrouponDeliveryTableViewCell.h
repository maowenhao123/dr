//
//  DRShipmentGrouponDeliveryTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DRShipmentModel.h"

@interface DRShipmentGrouponDeliveryTableViewCell : UITableViewCell

+ (DRShipmentGrouponDeliveryTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic,strong) DRDeliveryAddressModel * deliveryModel;

@end
