//
//  DRReturnGoodModel.m
//  dr
//
//  Created by 毛文豪 on 2017/6/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodModel.h"

@implementation DRReturnGoodModel

+ (void)initialize
{
    [DRReturnGoodModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"description_":@"description"
                 };
    }];
}

@end
