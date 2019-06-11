//
//  DRPraiseGoodAwardModel.h
//  dr
//
//  Created by 毛文豪 on 2019/1/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseGoodAwardModel : NSObject

@property (nonatomic, assign) long long createTime;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *morePics;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *repertory;
@property (nonatomic, copy) NSString *summary;

@end

NS_ASSUME_NONNULL_END
