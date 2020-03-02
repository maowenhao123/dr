//
//  DRGoodModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodModel.h"

@implementation DRGoodModel

MJCodingImplementation

+ (void)initialize
{
    [DRGoodModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{
            @"description_":@"description"
        };
    }];
}

@end
