//
//  DRIMTool.m
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRIMTool.h"

@implementation DRIMTool

+ (void)saveUserProfileWithUsername:(NSString *)username forNickName:(NSString *)nickName avatarURLPath:(NSString *)avatarURLPath{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //设置保存的头像和昵称的key，加上环信ID字段标识
    NSString *nickNameKey = [NSString stringWithFormat:@"username_%@",username];
    NSString *avatarURLPathKey = [NSString stringWithFormat:@"avatarURLPath_%@",username];
    
    [defaults setObject:nickName forKey:nickNameKey];
    [defaults setObject:avatarURLPath forKey:avatarURLPathKey];
    [defaults synchronize];
}

+ (NSString *)getNickNameWithUsername:(NSString*)username{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *nickNameKey = [NSString stringWithFormat:@"username_%@",username];
    
    return [defaults objectForKey:nickNameKey];
}

+ (NSString *)getavatarURLPathWithUsername:(NSString*)username{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *avatarURLPathKey = [NSString stringWithFormat:@"avatarURLPath_%@",username];
    
    return [defaults objectForKey:avatarURLPathKey];
}

+ (void)removeUserProfileWithUsername:(NSString *)username{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *nickNameKey = [NSString stringWithFormat:@"username_%@",username];
    NSString *avatarURLPathKey = [NSString stringWithFormat:@"avatarURLPath_%@",username];
    
    [defaults removeObjectForKey:nickNameKey];
    [defaults removeObjectForKey:avatarURLPathKey];
    [defaults synchronize];
}

@end
