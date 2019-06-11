//
//  DRGrouponModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRGrouponModel : NSObject

@property (nonatomic,assign) long long createTime;
@property (nonatomic,strong) DRGoodModel *goods;
@property (nonatomic,strong) NSNumber *plusCount;
@property (nonatomic,strong) NSNumber *price;
@property (nonatomic,strong) NSNumber *successCount;
@property (nonatomic,strong) NSNumber *waitPayCount;
@property (nonatomic,strong) NSNumber *payCount;//已团数
@property (nonatomic,copy) NSString *id;
@property (nonatomic,strong) NSNumber *status;//状态
@property (nonatomic,assign) int count;//购物车中该商品的数量

@end
