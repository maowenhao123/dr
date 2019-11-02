//
//  DRShoppingCarCache.m
//  dr
//
//  Created by dahe on 2019/10/30.
//  Copyright © 2019 JG. All rights reserved.
//
#define DRShoppingCarFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shoppingCar.data"]

#import "DRShoppingCarCache.h"
#import "DRShoppingCarShopModel.h"

@implementation DRShoppingCarCache

+ (void)addGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count specificationModel:(DRGoodSpecificationModel *)specificationModel
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    if (DRDictIsEmpty(carShopDic)) {
        carShopDic = [NSMutableDictionary dictionary];
    }
    //获取当前时间戳
    NSDate* date = [NSDate date];
    NSTimeInterval creatTime = [date timeIntervalSince1970];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[goodModel.store.id];
    if (!carShopModel) {
        carShopModel = [[DRShoppingCarShopModel alloc] init];
        carShopModel.creatTime = creatTime;
    }
    carShopModel.selected = NO;
    carShopModel.shopModel = goodModel.store;
    
    NSString * carGoodId = goodModel.id;
    if (!DRObjectIsEmpty(specificationModel)) {
        carGoodId = [NSString stringWithFormat:@"%@%@", carGoodId, specificationModel.id];
    }
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodDic[carGoodId];
    if (!carGoodModel) {
        carGoodModel = [[DRShoppingCarGoodModel alloc] init];
        carGoodModel.creatTime = creatTime;
        carGoodModel.selected = YES;
    }
    carGoodModel.count += count;
    if (!DRObjectIsEmpty(specificationModel)) {
        carGoodModel.specificationModel = specificationModel;
    }
    
    BOOL allSelected = YES;
    for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
        if (!carGoodModel.isSelected) {
            allSelected = NO;
            break;
        }
    }
    carShopModel.selected = allSelected;
    
    //批发根据数量改变价格
    if ([goodModel.sellType intValue] == 2) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
        NSArray *wholesaleRule = [goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
        
        for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
            int count = [wholesaleRuleDic[@"count"] intValue];
            if (carGoodModel.count >= count) {
                goodModel.price = [NSNumber numberWithInt:[wholesaleRuleDic[@"price"] intValue]];
                break;
            }
        }
    }
    carGoodModel.carGoodId = carGoodId;
    carGoodModel.goodModel = goodModel;
    
    [carShopModel.goodDic setValue:carGoodModel forKey:carGoodId];
    [carShopDic setValue:carShopModel forKey:goodModel.store.id];
    
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (void)upDataGoodInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel count:(int)count;
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[carGoodModel.goodModel.store.id];
    carGoodModel.count = count;
    //批发根据数量改变价格
    if ([carGoodModel.goodModel.sellType intValue] == 2) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
        NSArray *wholesaleRule = [carGoodModel.goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
        
        for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
            int count = [wholesaleRuleDic[@"count"] intValue];
            int price = [wholesaleRuleDic[@"price"] intValue];
            if (carGoodModel.count >= count) {
                carGoodModel.goodModel.price = @(price);
                break;
            }
        }
    }
    
    [carShopModel.goodDic setValue:carGoodModel forKey:carGoodModel.carGoodId];
    [carShopDic setValue:carShopModel forKey:carGoodModel.goodModel.store.id];
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (void)deleteGoodInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[carGoodModel.goodModel.store.id];
    if (carShopModel.goodDic.allKeys.count == 1) {//商店只有这一种商品
        [carShopDic removeObjectForKey:carGoodModel.goodModel.store.id];
    }else
    {
        [carShopModel.goodDic removeObjectForKey:carGoodModel.carGoodId];
        
        BOOL allSelected = YES;
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (!carGoodModel.isSelected) {
                allSelected = NO;
                break;
            }
        }
        carShopModel.selected = allSelected;
        
        [carShopDic setValue:carShopModel forKey:carGoodModel.goodModel.store.id];
    }
    
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (void)upDataGoodSelectedInShoppingCarWithCarGoodModel:(DRShoppingCarGoodModel *)carGoodModel selected:(BOOL)selected
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    DRShoppingCarShopModel * carShopModel = carShopDic[carGoodModel.goodModel.store.id];
    carGoodModel.selected = selected;
    BOOL allSelected = YES;
    if (selected == NO) {
        allSelected = NO;
    }else
    {
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (!carGoodModel.isSelected) {
                allSelected = NO;
                break;
            }
        }
    }
    carShopModel.selected = allSelected;
    [carShopModel.goodDic setValue:carGoodModel forKey:carGoodModel.carGoodId];
    [carShopDic setValue:carShopModel forKey:carGoodModel.goodModel.store.id];
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (void)upDataShopSelectedInShoppingCarWithShopId:(NSString *)shopId selected:(BOOL)selected
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    DRShoppingCarShopModel * carShopModel = carShopDic[shopId];
    carShopModel.selected = selected;
    [carShopDic setValue:carShopModel forKey:shopId];
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (NSArray *)getShoppingCarGoods
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    NSMutableArray *carShopArr = [NSMutableArray arrayWithArray:carShopDic.allValues];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creatTime" ascending:NO];
    carShopArr = [NSMutableArray arrayWithArray:[carShopArr sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return carShopArr;
}

+ (NSInteger)getShoppingCarGoodCount
{
    NSInteger goodCount = 0;
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    for (DRShoppingCarShopModel * carShopModel in carShopDic.allValues) {
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodDic.allValues) {
            goodCount += carGoodModel.count;
        }
    }
    return goodCount;
}

@end
