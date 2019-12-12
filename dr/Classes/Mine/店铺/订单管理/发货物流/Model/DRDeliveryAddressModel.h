//
//  DRDeliveryAddressModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRAddressModel.h"

@interface DRDeliveryAddressModel : NSObject

@property (nonatomic,strong) DRAddressModel *address;
@property (nonatomic,strong) NSNumber *count;//数量
@property (nonatomic,copy) NSString *orderDetailId;//团购订单号，只有团购并且直邮用户才有此字段
@property (nonatomic,strong) NSNumber *type;// 0 卖家直邮给用户， 1 卖家发给平台   2 平台发往用户
@property (nonatomic,strong) NSNumber *mailType;//快递方式 1 包邮  2 肉币支付  3 快递到付
@property (nonatomic,copy) NSString *logisticsName;//快递公司名称
@property (nonatomic,copy) NSString *logisticsNum;//快递号
@property (nonatomic,copy) NSString *groupId;//团购订单号，只有团购订单才有
@property (nonatomic,strong) NSNumber *freight;
@property (nonatomic,copy) NSString *remarks;
@property (nonatomic,strong) NSNumber *status;

//自定义
@property (nonatomic,strong) NSDictionary *deliveryDic;
@property (nonatomic,assign) CGSize nameSize;
@property (nonatomic,assign) CGSize phoneSize;
@property (nonatomic,assign) CGSize addressSize;
@property (nonatomic,assign) CGSize typeSize;
@property (nonatomic,assign) CGSize remarkSize;
@property (nonatomic,assign) CGSize countSize;
@property (nonatomic,assign) CGSize logisticsNameSize;
@property (nonatomic,assign) CGSize logisticsNumSize;
@property (nonatomic,assign) CGFloat cellH;

@end
