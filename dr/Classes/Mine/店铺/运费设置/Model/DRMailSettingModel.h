//
//  DRMailSettingModel.h
//  dr
//
//  Created by 毛文豪 on 2018/3/26.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRMailSettingModel : NSObject

@property (nonatomic,copy) NSString *conditionalMailId;
@property (nonatomic, strong) NSNumber * ruleMoney;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic, strong) NSNumber * openConditionalMail;
@property (nonatomic, strong) NSNumber * freight;

@property (nonatomic, copy) NSString *id;



@end
