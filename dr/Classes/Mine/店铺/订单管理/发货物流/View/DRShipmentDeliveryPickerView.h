//
//  DRShipmentDeliveryPickerView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^ShipmentDeliveryPickerViewBlock)(NSDictionary * deliveryDic);

@interface DRShipmentDeliveryPickerView : UIView

@property (copy, nonatomic)ShipmentDeliveryPickerViewBlock block;

- (void)show;

@end
