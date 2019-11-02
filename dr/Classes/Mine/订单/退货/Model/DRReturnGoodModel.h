//
//  DRReturnGoodModel.h
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRReturnGoodModel : NSObject

@property (nonatomic,copy) NSString *id;//退款申请Id
@property (nonatomic,strong) DRGoodModel *goods;//商品bean
@property (nonatomic,strong) DRShopModel *store;//店铺bean
@property (nonatomic,strong) DRUser *user; //用户bean
@property (nonatomic,copy) NSString *orderId;//订单号
@property (nonatomic,copy) NSString *goodsId;//商品Id
@property (nonatomic,strong) NSNumber *count;//退款数量
@property (nonatomic,strong) NSNumber *priceCount;//退款金额
@property (nonatomic,strong) NSNumber *couponPrice;//折扣金额
@property (nonatomic,strong) NSNumber *actualRefund;//实际退款金额
@property (nonatomic,strong) NSNumber *status; //状态
@property (nonatomic,copy) NSString *description_;//买家退款描述
@property (nonatomic,strong) NSArray *pictures;//上传图片
@property (nonatomic,assign) long long createTime;//退款发起时间
@property (nonatomic,assign) long long processTime;//处理时间
@property (nonatomic,copy) NSString *memo;//卖家备注
@property (nonatomic,strong) DRGoodSpecificationModel *specification;

@end


