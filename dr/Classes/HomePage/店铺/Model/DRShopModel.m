//
//  DRShopModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShopModel.h"

@implementation DRShopModel

MJCodingImplementation

+ (void)initialize
{
    [DRShopModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{
                 @"description_":@"description"
                 };
    }];
}

@end
