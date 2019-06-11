//
//  DRPraiseUserModel.h
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPraiseUserModel : NSObject

@property (nonatomic,copy) NSString *artId;
@property (nonatomic,assign) long long createTime;
@property (nonatomic,copy) NSString *userHeadImg;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userLoginName;
@property (nonatomic,copy) NSString *userNickName;

@end
