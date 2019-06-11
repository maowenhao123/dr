//
//  DRGrouponOrderModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRGrouponModel.h"
#import "DRAddressModel.h"
#import "DRStoreOrderModel.h"

@interface DRGrouponOrderModel : NSObject

@property (nonatomic,copy) NSString *id;//订单Id
@property (nonatomic,strong) NSNumber *status;//状态
@property (nonatomic,assign) long long createTime;//购买时间
@property (nonatomic,assign) long long deliverTime;//发货时间
@property (nonatomic,assign) long long takeTime;//取件时间
@property (nonatomic,strong) NSNumber *chargeType;//支付方式 0 账户支付 1 肉币支付
@property (nonatomic,strong) NSNumber *priceCount;
@property (nonatomic,strong) DRGrouponModel *group;
@property (nonatomic,strong) NSArray <DRStoreOrderModel *> *storeOrders;
@property (nonatomic,strong) DRAddressModel *address;//地址
@property (nonatomic,strong) NSNumber *mailPrice;//快递费用


@end
