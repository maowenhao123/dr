//
//  DRShipmentModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRStoreOrderModel.h"
#import "DRDeliveryAddressModel.h"
#import "DRShipmentGroupon.h"

@interface DRShipmentModel : NSObject

@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,strong) NSNumber *orderType;
@property (nonatomic,assign) long long orderTime;
@property (nonatomic,strong) NSNumber *priceCount;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,assign) long long deliverTime;
@property (nonatomic,strong) NSArray <DRDeliveryAddressModel *> *deliveryList;
@property (nonatomic,strong) DRStoreOrderModel*order;
@property (nonatomic,strong) DRUser *user;
@property (nonatomic,strong) NSArray <DRShipmentGroupon *> *groupItemDetailList;
@property (nonatomic,strong) NSNumber *mailType;//快递方式 1 包邮  2 肉币支付  3 快递到付
@property (nonatomic,strong) NSNumber *successCount;//成团数量
@property (nonatomic,strong) NSNumber *plusCount;//剩余数量
@property (nonatomic,strong) NSNumber *waitPayCount;//待支付数量
@property (nonatomic,strong) NSNumber *payCount;//已团数
@property (nonatomic,strong) NSNumber *freight;

@end
