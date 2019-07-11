//
//  DRVoucherModel.h
//  dr
//
//  Created by dahe on 2019/7/10.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRVoucherModel : NSObject

@property (nonatomic, copy) NSString *expiredTimeDesc;
@property (nonatomic, strong) NSNumber *money;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ruleDesc;

@end

NS_ASSUME_NONNULL_END
