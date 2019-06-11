//
//  DROrderLogisticsModel.h
//  dr
//
//  Created by 毛文豪 on 2017/6/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRLogisticsTraceModel.h"

@interface DROrderLogisticsModel : NSObject

@property (nonatomic,copy) NSString *id;
@property (nonatomic,assign) long long createTime;//发货时间
@property (nonatomic,strong) NSNumber *type;// 1 快递到用户，2 快递到 平台
@property (nonatomic,copy) NSString *logisticsCode;//快递公司代码
@property (nonatomic,copy) NSString *logisticsName;//快递公司名称
@property (nonatomic,copy) NSString *logisticsNum;//快递号
@property (nonatomic,strong) NSArray <DRLogisticsTraceModel *> *traces;

@end
