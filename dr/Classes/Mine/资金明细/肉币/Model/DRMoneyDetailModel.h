//
//  DRMoneyDetailModel.h
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DROrderModel.h"

@interface DRMoneyDetailModel : NSObject

@property (nonatomic, copy) NSString * money;//发生额
@property (nonatomic, copy) NSString * balance;//余额
@property (nonatomic, copy) NSString * extendId;
@property (nonatomic, copy) NSString * remark;
@property (nonatomic, assign) long long monthCreateTime;
@property (nonatomic, assign) long long createTime;//时间
@property (nonatomic, strong) NSNumber * type;//类型，1 充值， 2 退款 ，3 卖货 11 消费， 12 提现， 13 退货
@property (nonatomic, strong) DROrderModel *detail;//订单商品明细
@property (nonatomic, strong) NSNumber * status;

//自定义
@property (nonatomic, copy) NSString *month;//月份
@property (nonatomic, assign, getter=isOpen) BOOL open;//是否打开

@end
