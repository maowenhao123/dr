//
//  DRUser.h
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "JSONModel.h"

@interface DRUser : JSONModel

@property (nonatomic,copy) NSString *id;
@property (nonatomic, copy) NSString *loginName;//登录名字
@property (nonatomic, assign) BOOL hasFundPassword;//是否已经设置支付密码
@property (nonatomic, copy) NSString *balance;//余额
@property (nonatomic, copy) NSString *nickName;//昵称
@property (nonatomic, strong) NSNumber *type;//0是未开店。1是已开店
@property (nonatomic, strong) NSNumber *status;//
@property (nonatomic, copy) NSString *realName;//真实姓名
@property (nonatomic, copy) NSString *personalId;//身份证号
@property (nonatomic, copy) NSString *phone;//电话
@property (nonatomic, strong) NSNumber *sex;//性别
@property (nonatomic, copy) NSString *birthday;//生日
@property (nonatomic, copy) NSString *headImg;
@property (nonatomic,copy) NSString *idCardImg;//身份证正面
@property (nonatomic,copy) NSString *idCardBackImg;//身份证反面
@property (nonatomic,copy) NSString *idCardHoldImg;
@property (nonatomic, strong) NSNumber *couponNumber;//可用红包数量
@property (nonatomic, strong) NSNumber *waitPayCount;//待付款
@property (nonatomic, strong) NSNumber *waitDeliveryCount;//待发货
@property (nonatomic, strong) NSNumber *waitReceiveCount;//待收货
@property (nonatomic, strong) NSNumber *waitGroupCount;//待成团
@property (nonatomic, strong) NSNumber *waitCommentCount;//待评价
@property (nonatomic, strong) NSNumber * waitRefundCount;//待退款

@end
