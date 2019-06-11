//
//  DROrderModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRAddressModel.h"
#import "DRStoreOrderModel.h"
#import "DRGrouponModel.h"

@interface DROrderModel : NSObject

@property (nonatomic,copy) NSString *id;//订单Id
@property (nonatomic,strong) NSNumber *priceCount;//总价格
@property (nonatomic,strong) NSNumber *status;//状态
@property (nonatomic,assign) long long createTime;//购买时间
@property (nonatomic,assign) long long deliverTime;//发货时间
@property (nonatomic,assign) long long takeTime;//取件时间
@property (nonatomic,strong) NSNumber *chargeType;//支付方式 0 账户支付 1 肉币支付
@property (nonatomic,strong) NSNumber *orderType;//订单类型 2 团购 1 普通
@property (nonatomic,strong) NSArray <DRStoreOrderModel *> *storeOrders;//订单商品明细
@property (nonatomic,strong) DRAddressModel *address;//地址
@property (nonatomic,strong) DRGrouponModel *group;//团购详情
@property (nonatomic,strong) NSNumber *mailType;//快递方式 1包邮 2肉币支付 3快递到付
@property (nonatomic,strong) NSNumber *mailPrice;//快递费用
@property (nonatomic,strong) NSNumber *amountPayable;//实付金额
@property (nonatomic,strong) NSNumber *couponPrice;//折扣金额
@property (nonatomic,strong) NSNumber *unCommentCount;//为评论数
@property (nonatomic,strong) NSNumber *freight;
@property (nonatomic,strong) NSNumber *successCount;//
@property (nonatomic,strong) NSNumber *plusCount;//
@property (nonatomic,strong) NSNumber *sellCount;//
@property (nonatomic,strong) NSNumber *price;//
@property (nonatomic,copy) NSString *storeId;
@property (nonatomic,copy) NSString *storeName;//店铺名称
@property (nonatomic,copy) NSString *storeImg;//店铺LOGO

@end
