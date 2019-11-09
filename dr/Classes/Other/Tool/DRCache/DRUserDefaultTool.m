//
//  DRUserDefaultTool.m
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRUserDefaultTool.h"

#define DRUserFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.data"]
#define DRMyShopModelFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"myShopModel.data"]

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
    if ([defaultManager isDeletableFileAtPath:DRMyShopModelFile]) {
        [defaultManager removeItemAtPath:DRMyShopModelFile error:nil];
    }
}


@end
