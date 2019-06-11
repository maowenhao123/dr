//
//  DRShipmentGrouponLogisticsAddressTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShipmentModel.h"

@class DRShipmentGrouponLogisticsAddressTableViewCell;
@protocol ShipmentGrouponLogisticsAddressTableViewCellDelegate <NSObject>

- (void)shipmentGrouponLogisticsAddressTableViewCell:(DRShipmentGrouponLogisticsAddressTableViewCell *)cell logisticsButtonDidClick:(UIButton *)button;

@end

@interface DRShipmentGrouponLogisticsAddressTableViewCell : UITableViewCell

+ (DRShipmentGrouponLogisticsAddressTableViewCell *)cellWithTableView:(UITableView *)tableView;

/**
 协议
 */
@property (nonatomic, weak) id <ShipmentGrouponLogisticsAddressTableViewCellDelegate> delegate;

@property (nonatomic,strong) DRDeliveryAddressModel * deliveryModel;

@end
