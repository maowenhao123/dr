//
//  DRAwardModel.h
//  dr
//
//  Created by 毛文豪 on 2019/1/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRAwardModel : NSObject

@property (nonatomic, copy) NSString * id;
@property (nonatomic, strong) NSNumber *receiveType; //1领取多肉 2红包
@property (nonatomic, strong) NSNumber *status; //0未领取 1已领取
@property (nonatomic, strong) NSNumber *type; //1领取周 2总
@property (nonatomic, copy) NSString *receiveId;

@end

NS_ASSUME_NONNULL_END
