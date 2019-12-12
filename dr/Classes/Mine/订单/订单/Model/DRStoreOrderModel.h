//
//  DRStoreOrderModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DROrderItemDetailModel.h"

@interface DRStoreOrderModel : NSObject

@property (nonatomic,copy) NSString *storeId;//店铺Id
@property (nonatomic,copy) NSString *storeName;// 店铺名称
@property (nonatomic,copy) NSString *storeImg;// 店铺LOGO
@property (nonatomic,strong) NSNumber *priceCount;//店铺内总价格
@property (nonatomic,strong) NSNumber *ruleMoney;//满**包邮
@property (nonatomic,strong) NSNumber *freight;//邮费
@property (nonatomic,strong) NSNumber *mailType;//快递方式 1 包邮 2 肉币支付 3 快递到付
@property (nonatomic,strong) NSArray <DROrderItemDetailModel *> *detail;
@property (nonatomic,copy) NSString *remarks;

@end
