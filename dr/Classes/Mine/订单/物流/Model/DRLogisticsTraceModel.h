//
//  DRLogisticsTraceModel.h
//  dr
//
//  Created by 毛文豪 on 2017/6/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRLogisticsTraceModel : NSObject

@property (nonatomic,assign) long long time;//时间
@property (nonatomic,copy) NSString *desc;

//自定义
@property (nonatomic,copy) NSMutableAttributedString * contentAttStr;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL isLast;
@property (nonatomic,assign) CGFloat cellH;

@end
