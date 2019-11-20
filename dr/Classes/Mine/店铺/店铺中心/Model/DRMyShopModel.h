//
//  DRMyShopModel.h
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRMyShopModel : NSObject

@property (nonatomic, copy) NSString * deliverAddress;//发货地址
@property (nonatomic, copy) NSString * storeName;//店铺名称
@property (nonatomic, copy) NSString * storeImg;//店铺图片
@property (nonatomic, copy) NSString * description_;//店铺描述
@property (nonatomic, strong) NSNumber * fansCount;//关注数量
@property (nonatomic, strong) NSNumber * sellCount;//销售总数
@property (nonatomic, strong) NSNumber * allIncome;//销售总额
@property (nonatomic, strong) NSNumber * totalIncome;//总收入
@property (nonatomic, strong) NSNumber * receivables;//待收款
@property (nonatomic, strong) NSNumber *withdrawMoney;//已提款
@property (nonatomic, strong) NSNumber * todaySaleCount;//今日卖出数量
@property (nonatomic, strong) NSNumber * todayIncome;//今日收入
@property (nonatomic, assign) long long createTime;
@property (nonatomic, strong) NSNumber * finishedIncome;
@property (nonatomic, strong) NSNumber * monthIncome;
@property (nonatomic, strong) NSNumber * monthSaleCount;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, strong) NSNumber * unfinishedIncome;
@property (nonatomic, strong) NSNumber *balance;//余额
@property (nonatomic,copy) NSString *id;
@property (nonatomic, strong) NSNumber * waitDeliveryCount;	// 待发货数量
@property (nonatomic, strong) NSNumber * waitPayCount;		//待支付数量
@property (nonatomic, strong) NSNumber * waitReceiveCount;	//待收货数量
@property (nonatomic, strong) NSNumber * waitRefundCount;	//待退款数量
@property (nonatomic, strong) NSNumber * waitPendingRegimentCount;//待成团
@property (nonatomic,strong) NSArray <NSString *>*tags;

@end
