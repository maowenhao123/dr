//
//  DRShopModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRShopModel : NSObject

@property (nonatomic, assign) long long createTime;
@property (nonatomic, copy) NSString *deliverAddress;
@property (nonatomic, copy) NSString *description_;
@property (nonatomic, strong) NSNumber *goodscount;
@property (nonatomic, strong) NSNumber *fansCount;
@property (nonatomic, strong) NSNumber *sellCount;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *storeImg;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,strong) NSArray *recommendGoods;
@property (nonatomic, strong) NSNumber *freight;
@property (nonatomic, strong) NSNumber *ruleMoney;
@property (nonatomic,strong) NSArray <NSString *>*tags;

@end
