//
//  DRSearchTool.m
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSearchTool.h"

#define GoodHistoryFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"goodHistory.data"]
#define GroupHistoryFile [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"groupHistory.data"]

@implementation DRSearchTool

+ (NSArray *)getGoodHistoryData
{
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithFile:GoodHistoryFile];
    return array;
}
+ (void)addGoodKeyWord:(NSString *)keyWord
{
    NSArray * array = [NSArray array];
    NSMutableArray * muArray = [NSMutableArray arrayWithArray:[self getGoodHistoryData]];
    [muArray removeObject:keyWord];
    [muArray insertObject:keyWord atIndex:0];
    //最多存15个历史数据
    if (muArray.count > 15) {
        array = [muArray subarrayWithRange:NSMakeRange(0, 15)];
    }else
    {
        array = [NSArray arrayWithArray:muArray];
    }
    [NSKeyedArchiver archiveRootObject:array toFile:GoodHistoryFile];
}
+ (void)deleteGoodHistoryData
{
    [NSKeyedArchiver archiveRootObject:[NSArray array] toFile:GoodHistoryFile];
}

+ (NSArray *)getGroupHistoryData
{
    NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithFile:GroupHistoryFile];
    return array;
}
+ (void)addGroupKeyWord:(NSString *)keyWord
{
    NSArray * array = [NSArray array];
    NSMutableArray * muArray = [NSMutableArray arrayWithArray:[self getGroupHistoryData]];
    [muArray removeObject:keyWord];
    [muArray insertObject:keyWord atIndex:0];
    //最多存15个历史数据
    if (muArray.count > 15) {
        array = [muArray subarrayWithRange:NSMakeRange(0, 15)];
    }else
    {
        array = [NSArray arrayWithArray:muArray];
    }
    [NSKeyedArchiver archiveRootObject:array toFile:GroupHistoryFile];
}
+ (void)deleteGroupHistoryData
{
    [NSKeyedArchiver archiveRootObject:[NSArray array] toFile:GroupHistoryFile];
}

@end
