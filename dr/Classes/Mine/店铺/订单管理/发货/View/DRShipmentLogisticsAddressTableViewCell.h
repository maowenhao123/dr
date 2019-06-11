//
//  DRShipmentLogisticsAddressTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShipmentModel.h"

@class DRShipmentLogisticsAddressTableViewCell;
@protocol ShipmentLogisticsAddressTableViewCellDelegate <NSObject>

- (void)shipmentLogisticsAddressTableViewCell:(DRShipmentLogisticsAddressTableViewCell *)cell logisticsButtonDidClick:(UIButton *)button;

@end

@interface DRShipmentLogisticsAddressTableViewCell : UITableViewCell

+ (DRShipmentLogisticsAddressTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 协议
 */
@property (nonatomic, weak) id <ShipmentLogisticsAddressTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRDeliveryAddressModel * deliveryModel;

@end
