//
//  DRValidateTool.h
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRValidateTool : NSObject

//银行卡号码
+ (BOOL) validateCardNumber:(NSString *)cardNumber;

//手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile;


//密码
+ (BOOL) validatePassword:(NSString *)passWord;

//支付密码
+ (BOOL) validateFunPassword:(NSString *)passWord;

//昵称
+ (BOOL) validateNickname:(NSString *)nickname;

//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard;


@end
