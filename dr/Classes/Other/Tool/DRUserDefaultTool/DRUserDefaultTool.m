//
//  DRUserDefaultTool.m
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRUserDefaultTool.h"
#import "DRShoppingCarShopModel.h"

#define DRUserFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.data"]
#define DRMyShopModelFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"myShopModel.data"]
#define DRShoppingCarFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shoppingCar.data"]

@implementation DRUserDefaultTool

#pragma mark - 自定义
+ (void)saveObject:(NSString *)object forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}
+ (NSString *)getObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return  [defaults stringForKey:key];
}
+ (void)removeObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}
+ (void)saveInt:(int)integer forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:integer forKey:key];
    [defaults synchronize];
}
+ (int)getIntForKey:(NSString *)key//取出整型
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:key];
}
#pragma mark - 用户信息
+ (void)saveUser:(DRUser *)user
{
    [NSKeyedArchiver archiveRootObject:user toFile:DRUserFile];
}
+ (DRUser *)user
{
    DRUser *user = [NSKeyedUnarchiver unarchiveObjectWithFile:DRUserFile];
    return user;
}
+ (void)removeUser
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isDeletableFileAtPath:DRUserFile]) {
        [defaultManager removeItemAtPath:DRUserFile error:nil];
    }
}
#pragma mark - 我的店铺
+ (void)saveMyShopModel:(DRMyShopModel *)myShopModel
{
    [NSKeyedArchiver archiveRootObject:myShopModel toFile:DRMyShopModelFile];
}
+ (DRMyShopModel *)myShopModel
{
    DRMyShopModel *myShopModel = [NSKeyedUnarchiver unarchiveObjectWithFile:DRMyShopModelFile];
    return myShopModel;
}
+ (void)removeShop
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isDeletableFileAtPath:DRUserFile]) {
        [defaultManager removeItemAtPath:DRUserFile error:nil];
    }
}
#pragma mark - 购物车
+ (void)addGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count
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
    
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodDic[goodModel.id];
    if (!carGoodModel) {
        carGoodModel = [[DRShoppingCarGoodModel alloc] init];
        carGoodModel.creatTime = creatTime;
    }
    carGoodModel.count += count;
    
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

    carGoodModel.goodModel = goodModel;
    
    [carShopModel.goodDic setValue:carGoodModel forKey:goodModel.id];
    [carShopDic setValue:carShopModel forKey:goodModel.store.id];
    
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}

+ (void)upDataGoodInShoppingCarWithGood:(DRGoodModel *)goodModel count:(int)count
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[goodModel.store.id];
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodDic[goodModel.id];
    carGoodModel.goodModel = goodModel;
    carGoodModel.count = count;
    //批发根据数量改变价格
    if ([goodModel.sellType intValue] == 2) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
        NSArray *wholesaleRule = [goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
        
        for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
            int count = [wholesaleRuleDic[@"count"] intValue];
            if (carGoodModel.count >= count) {
                goodModel.price = [NSNumber numberWithInt:[wholesaleRuleDic[@"price"] intValue]];
                carGoodModel.goodModel = goodModel;
                break;
            }
        }
    }
    
    [carShopModel.goodDic setValue:carGoodModel forKey:goodModel.id];
    [carShopDic setValue:carShopModel forKey:goodModel.store.id];
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}
+ (void)deleteGoodInShoppingCarWithGood:(DRGoodModel *)goodModel
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[goodModel.store.id];
    if (carShopModel.goodDic.allKeys.count == 1) {//商店只有这一种商品
        [carShopDic removeObjectForKey:goodModel.store.id];
    }else
    {
        [carShopModel.goodDic removeObjectForKey:goodModel.id];
        
        BOOL allSelected = YES;
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (!carGoodModel.isSelected) {
                allSelected = NO;
                break;
            }
        }
        carShopModel.selected = allSelected;
        
        [carShopDic setValue:carShopModel forKey:goodModel.store.id];
    }
    
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}
+ (void)reduceGoodInShoppingCarWithGood:(DRGoodModel *)goodModel
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    
    DRShoppingCarShopModel * carShopModel = carShopDic[goodModel.store.id];
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodDic[goodModel.id];

    if (carShopModel.goodDic.allKeys.count == 1) {//商店只有这一种商品
        if (carGoodModel.count == 1) {//商品只有一件
            [carShopDic removeObjectForKey:goodModel.store.id];
        }else
        {
            carGoodModel.count--;
            //批发根据数量改变价格
            if ([goodModel.sellType intValue] == 2) {
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
                NSArray *wholesaleRule = [goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
                
                for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
                    int count = [wholesaleRuleDic[@"count"] intValue];
                    if (carGoodModel.count >= count) {
                        goodModel.price = [NSNumber numberWithInt:[wholesaleRuleDic[@"price"] intValue]];
                        carGoodModel.goodModel = goodModel;
                        break;
                    }
                }
            }

            BOOL allSelected = YES;
            for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
                if (!carGoodModel.isSelected) {
                    allSelected = NO;
                    break;
                }
            }
            carShopModel.selected = allSelected;
            
            [carShopModel.goodDic setValue:carGoodModel forKey:goodModel.id];
            [carShopDic setValue:carShopModel forKey:goodModel.store.id];
        }
    }else
    {
        if (carGoodModel.count == 1) {
            [carShopModel.goodDic removeObjectForKey:goodModel.id];
        }else
        {
            carGoodModel.count--;
            //批发根据数量改变价格
            if ([goodModel.sellType intValue] == 2) {
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
                NSArray *wholesaleRule = [goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
                
                for (NSDictionary * wholesaleRuleDic in wholesaleRule) {
                    int count = [wholesaleRuleDic[@"count"] intValue];
                    if (carGoodModel.count >= count) {
                        goodModel.price = [NSNumber numberWithInt:[wholesaleRuleDic[@"price"] intValue]];
                        carGoodModel.goodModel = goodModel;
                        break;
                    }
                }
            }

            [carShopModel.goodDic setValue:carGoodModel forKey:goodModel.id];
        }
        
        BOOL allSelected = YES;
        for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
            if (!carGoodModel.isSelected) {
                allSelected = NO;
                break;
            }
        }
        carShopModel.selected = allSelected;
        
        [carShopDic setValue:carShopModel forKey:goodModel.store.id];
    }
    
    [NSKeyedArchiver archiveRootObject:carShopDic toFile:DRShoppingCarFile];
}
+ (void)upDataShopSelectedInShoppingCarWithShopId:(NSString *)shopId selected:(BOOL)selected
{
    
}
+ (void)upDataGoodSelectedInShoppingCarWithGood:(DRGoodModel *)goodModel selected:(BOOL)selected
{
    NSMutableDictionary *carShopDic = [NSKeyedUnarchiver unarchiveObjectWithFile:DRShoppingCarFile];
    DRShoppingCarShopModel * carShopModel = carShopDic[goodModel.store.id];
    DRShoppingCarGoodModel * carGoodModel = carShopModel.goodDic[goodModel.id];
    carGoodModel.selected = selected;
    BOOL allSelected = YES;
    for (DRShoppingCarGoodModel * carGoodModel in carShopModel.goodArr) {
        if (!carGoodModel.isSelected) {
            allSelected = NO;
            break;
        }
    }
    carShopModel.selected = allSelected;
    [carShopModel.goodDic setValue:carGoodModel forKey:goodModel.id];
    [carShopDic setValue:carShopModel forKey:goodModel.store.id];
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
