//
//  DRShoppingCarCache.h
//  dr
//
//  Created by dahe on 2019/10/30.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRShoppingCarGoodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRShoppingCarCache : NSObject

+ (void)addGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count specificationModel:(DRGoodSpecificationModel *)specificationModel;//把商品存入购物车
+ (void)upDataGoodInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel count:(int)count;//更新购物车中商品数量
+ (void)deleteGoodInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel;//丛购物车中删除商品
+ (void)upDataGoodSelectedInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel selected:(BOOL)selected;
+ (void)upDataShopSelectedInShoppingCarWithShopId:(NSString *)shopId selected:(BOOL)selected;//跟新购物车里商品选中状态
+ (NSArray *)getShoppingCarGoods;//获取购物车中的商品
+ (NSInteger)getShoppingCarGoodCount;//获取购物车中的商品数量

@end

NS_ASSUME_NONNULL_END
