//
//  DRPraiseModel.h
//  dr
//
//  Created by 毛文豪 on 2018/12/27.
//  Copyright © 2018 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseModel : NSObject

@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSNumber *focusCount;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pics;
@property (nonatomic, copy) NSString *praiseCount;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *userHeadImg;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userLoginName;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, strong) NSNumber *focus;

@end

NS_ASSUME_NONNULL_END
