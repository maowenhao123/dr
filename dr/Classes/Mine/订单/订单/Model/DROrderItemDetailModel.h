//
//  DROrderItemDetailModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DROrderItemDetailModel : NSObject

@property (nonatomic,strong) DRGoodModel *goods;
@property (nonatomic,strong) NSNumber *purchaseCount;//商品购买总数
@property (nonatomic,strong) NSNumber *priceCount;//总价格
@property (nonatomic,strong) NSNumber *commentStatus;//0 为评价  1 已评价
@property (nonatomic,strong) NSNumber *refundStatus;//0 未退款  10 待审核退款 20 审核通过 -1 驳回
@property (nonatomic,strong) DRGoodSpecificationModel *specification;

@end
