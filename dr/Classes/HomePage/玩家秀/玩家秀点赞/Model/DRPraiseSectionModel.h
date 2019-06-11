//
//  DRPraiseSectionModel.h
//  dr
//
//  Created by 毛文豪 on 2018/12/27.
//  Copyright © 2018 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRPraiseModel.h"
#import "DRAwardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseSectionModel : NSObject

@property (nonatomic, copy) NSString *cycle;
@property (nonatomic, assign) long long beginCycle;
@property (nonatomic, assign) long long endCycle;
@property (nonatomic, assign) long long endTime;
@property (nonatomic, strong) NSMutableArray *praiseList;
@property (nonatomic, strong) NSMutableArray *awardList;
@property (nonatomic, strong) NSNumber *type; //1领取周 2总

@property (nonatomic, assign) CGRect weekViewF;
@property (nonatomic, assign) CGRect resultLabelF;
@property (nonatomic, assign) CGRect redPacketAwardViewF;
@property (nonatomic, assign) CGRect goodAwardViewF;
@property (nonatomic, assign) CGFloat cellH;

@end

NS_ASSUME_NONNULL_END
