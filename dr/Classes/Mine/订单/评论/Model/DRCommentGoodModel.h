//
//  DRCommentGoodModel.h
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRCommentGoodModel : NSObject

@property (nonatomic, copy) NSString * id;
@property (nonatomic,strong) DRGoodModel *goods;
@property (nonatomic,strong) NSNumber *commentStatus;//0 未评价 1 已评价
@property (nonatomic,copy) NSString *orderId;
@property (nonatomic,strong) NSNumber *price;//商品单价
@property (nonatomic,strong) NSNumber *priceCount;//改商品总金额
@property (nonatomic,strong) NSNumber *couponPrice;//折扣金额
@property (nonatomic,strong) NSNumber *orderPriceCount;//子订单总价
@property (nonatomic,strong) NSNumber *purchaseCount;//购买数量
@property (nonatomic,strong) NSNumber *refundStatus;//退款状态 INIT(0,"未退款"), AUDIT(10,"待审核退款"),PASS(20,"审核通过"),REJECT(-1,"驳回");
@property (nonatomic,strong) DRGoodSpecificationModel *specification;

@end
