//
//  DRSearchTool.h
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRSearchTool : NSObject

+ (NSArray *)getGoodHistoryData;//获取商品历史搜索结果
+ (void)addGoodKeyWord:(NSString *)keyWord;//添加商品历史搜索关键字
+ (void)deleteGoodHistoryData;//删除商品历史搜索结果

+ (NSArray *)getGroupHistoryData;//获取团购历史搜索结果
+ (void)addGroupKeyWord:(NSString *)keyWord;//添加团购历史搜索关键字
+ (void)deleteGroupHistoryData;//删除团购历史搜索结果

@end
