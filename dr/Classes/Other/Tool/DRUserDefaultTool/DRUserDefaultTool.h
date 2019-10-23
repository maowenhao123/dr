//
//  DRUserDefaultTool.h
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRMyShopModel.h"

@interface DRUserDefaultTool : NSObject

+ (void)saveObject:(NSString *)object forKey:(NSString *)key;//保存键值
+ (NSString *)getObjectForKey:(NSString *)key;//取出值

+ (void)saveInt:(int)integer forKey:(NSString *)key;//保存整型
+ (int)getIntForKey:(NSString *)key;//取出整型

+ (void)removeObjectForKey:(NSString *)key;//移除键值

+ (void)saveUser:(DRUser *)user;//存储用户所有信息
+ (DRUser *)user;//取出用户所有信息
+ (void)removeUser;

+ (void)saveMyShopModel:(DRMyShopModel *)myShopModel;//存储我的店铺信息
+ (DRMyShopModel *)myShopModel;//取出我的店铺信息
+ (void)removeShop;

+ (void)addGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count;//把商品存入购物车
+ (void)upDataGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count;//更新购物车中商品数量
+ (void)deleteGoodInShoppingCarWithGood:(DRGoodModel *)goodModel;//丛购物车中删除商品
+ (void)reduceGoodInShoppingCarWithGood:(DRGoodModel *)goodModel;//丛购物车中减少单商品
+ (void)upDataShopSelectedInShoppingCarWithShopId:(NSString *)shopId selected:(BOOL)selected;//跟新购物车里店铺选中状态
+ (void)upDataGoodSelectedInShoppingCarWithGood:(DRGoodModel *)goodModel selected:(BOOL)selected;//跟新购物车里商品选中状态
+ (NSArray *)getShoppingCarGoods;//获取购物车中的商品
+ (NSInteger)getShoppingCarGoodCount;//获取购物车中的商品数量

@end
