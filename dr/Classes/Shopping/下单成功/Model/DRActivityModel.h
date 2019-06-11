//
//  DRActivityModel.h
//  dr
//
//  Created by 毛文豪 on 2018/11/27.
//  Copyright © 2018 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRActivityModel : NSObject

@property (nonatomic, copy) NSString *background;
@property (nonatomic, copy) NSString *button;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
