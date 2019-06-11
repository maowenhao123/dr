//
//  DRMoneyDetailSectionModel.h
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRMoneyDetailModel.h"

@interface DRMoneyDetailSectionModel : NSObject

@property (nonatomic, assign) long long createTime;//时间
@property (nonatomic, copy) NSString * month;
@property (nonatomic, copy) NSString *expenditure;
@property (nonatomic, copy) NSString *income;
@property (nonatomic, strong) NSMutableArray * moneyDetails;

@end
