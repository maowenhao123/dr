//
//  DRUpgradeModel.m
//  dr
//
//  Created by 毛文豪 on 2017/10/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRUpgradeModel.h"

@implementation DRUpgradeModel

+ (void)initialize
{
    [DRUpgradeModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        
        return @{
                 @"description_":@"description",
                 };
    }];
}

@end
