//
//  DRRedPacketModel.h
//  dr
//
//  Created by 毛文豪 on 2018/2/1.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Coupon : NSObject

@property (nonatomic,copy) NSString *id;
@property (nonatomic,assign) BOOL isNewRecord;
@property (nonatomic,copy) NSString *sellerId;
@property (nonatomic,copy) NSString *couponName;
@property (nonatomic,copy) NSString *prefix;
@property (nonatomic,copy) NSString *couponValue;
@property (nonatomic,copy) NSString *minAmount;
@property (nonatomic,assign) long long sendStartTime;
@property (nonatomic,assign) long long sendEndTime;
@property (nonatomic,assign) long long useStartTime;
@property (nonatomic,assign) long long useEndTime;
@property (nonatomic,strong) NSNumber *personLimitNum;
@property (nonatomic,strong) NSNumber *totalLimitNum;
@property (nonatomic,strong) NSNumber *receivedNum;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *channel;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *auditOpinion;
@property (nonatomic,copy) NSString *remark;
@property (nonatomic,copy) NSString *auditUserId;
@property (nonatomic,copy) NSString *auditUserName;
@property (nonatomic,assign) long long auditTime;
@property (nonatomic,copy) NSString *createUserId;
@property (nonatomic,copy) NSString *createUserName;
@property (nonatomic,assign) long long createTime;
@property (nonatomic,copy) NSString *updateUserId;
@property (nonatomic,copy) NSString *updateUserName;
@property (nonatomic,assign) long long updateTime;

@end

@interface CouponUser : NSObject

@property (nonatomic,copy) NSString *id;
@property (nonatomic,assign) BOOL isNewRecord;
@property (nonatomic,copy) NSString *memberId;
@property (nonatomic,copy) NSString *sellerId;
@property (nonatomic,copy) NSString *couponId;
@property (nonatomic,copy) NSString *couponSn;
@property (nonatomic,copy) NSString *canUse;
@property (nonatomic,assign) long long receiveTime;
@property (nonatomic,assign) long long useStartTime;
@property (nonatomic,assign) long long useEndTime;
@property (nonatomic,copy) NSString *createUserId;
@property (nonatomic,copy) NSString *createUserName;
@property (nonatomic,assign) long long createTime;
@property (nonatomic,copy) NSString *updateUserId;
@property (nonatomic,copy) NSString *updateUserName;
@property (nonatomic,assign) long long updateTime;
@property (nonatomic,copy) NSString *memberName;
@property (nonatomic,copy) NSString *couponName;
@property (nonatomic,copy) NSString *couponValue;
@property (nonatomic,copy) NSString *minAmount;
@property (nonatomic,assign) BOOL timeout;
@property (nonatomic,copy) NSString *channel;
@property (nonatomic,assign) BOOL isuse;

@end

@interface DRRedPacketModel : NSObject

@property (nonatomic,strong) Coupon *coupon;
@property (nonatomic,strong) CouponUser *couponUser;

@end
