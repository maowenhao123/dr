//
//  DRSortModel.h
//  dr
//
//  Created by apple on 2017/3/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRSortModel : NSObject

@property (nonatomic, copy) NSString * name;//分类

@property (nonatomic, assign ,getter = isSelected) BOOL selected;//是否被选中

@property (nonatomic,copy) NSString *id;

@property (nonatomic,copy) NSString *logo;

@end
