//
//  DRSeckillGoodModel.h
//  dr
//
//  Created by dahe on 2019/11/4.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRSeckillGoodModel : NSObject

@property (nonatomic, copy) NSString *activityStock;
@property (nonatomic, copy) NSString *discountPrice;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *spreadPics;
@property (nonatomic, copy) NSString *activityId;
/*
 status=0  待审核
 status=1  审核通过
 status=2  驳回
 status=3  下架*/
@property (nonatomic, copy) NSString *status;

@end

NS_ASSUME_NONNULL_END
