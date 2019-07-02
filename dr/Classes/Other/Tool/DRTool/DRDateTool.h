//
//  DRDateTool.h
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRDateTool : NSObject
/**
 通过时间戳获取时间
 */
+ (NSString *)getTimeByTimestamp:(long long)timestamp format:(NSString *)format;
/**
 *  从字符串获取星期几
 */
+ (NSString *)getWeekFromDateString:(NSString *)dateString format:(NSString *)format;
/**
 *  从日期字符串获取格式为：2014年11月21日 星期五
 */
+ (NSString *)getChineseDateStringFromDateString:(NSString *)dateString format:(NSString *)format;
/*
 获取时间差
 */
+ (NSDateComponents *)getDeltaDateToDateString:(NSString *)dateString format:(NSString *)format;
+ (NSDateComponents *)getDeltaDateToTimestampg:(long long)timestamp;
/*
 获取两个时间段的时间差
 */
+ (NSDateComponents *)getDeltaDateFromDateString:(NSString *)fromDateString fromFormat:(NSString *)fromFormat toDateString:(NSString *)toDateString ToFormat:(NSString *)toFormat;
+ (NSDateComponents *)getDeltaDateFromTimestamp:(long long)formTimestamp fromFormat:(NSString *)fromFormat toTimestamp:(long long)toTimestamp ToFormat:(NSString *)toFormat;
/*
 把秒数转化成时间
 */
+ (NSDateComponents *)getDateComponentsBySeconds:(NSInteger)seconds;

/*
 把时间字符串转化成date
 */
+ (NSDate *)getDateFromDateString:(NSString *)dateString format:(NSString *)format;

@end
