//
//  DRShopActivityModel.h
//  dr
//
//  Created by 毛文豪 on 2019/1/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRShopActivityModel : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, assign) long long beginTime;
@property (nonatomic, assign) long long endTime;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *rule;

@end

NS_ASSUME_NONNULL_END
