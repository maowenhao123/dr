//
//  DRShowPraiseModel.h
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPraiseUserModel.h"

@interface DRShowPraiseModel : NSObject

@property (nonatomic, strong) NSArray <DRPraiseUserModel *>*praiseList;//点赞列表
@property (nonatomic, strong) NSNumber * praiseCount;//点赞数

//自定义
@property (nonatomic,strong) NSMutableArray *praiseButtonFs;
@property (nonatomic, assign) CGFloat cellH;

@end
