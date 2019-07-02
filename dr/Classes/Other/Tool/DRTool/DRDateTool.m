//
//  DRDateTool.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRDateTool.h"

@implementation DRDateTool

+ (NSDate *)getTimeDateByTimestamp:(long long)timestamp format:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    return date;
}
+ (NSString *)getTimeByTimestamp:(long long)timestamp format:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)getWeekFromDateString:(NSString *)dateString format:(NSString *)format
{
    NSDate *date = [self getDateFromDateString:dateString format:format];
    return [self getWeekFromDate:date];
}

+ (NSString *)getChineseDateStringFromDateString:(NSString *)dateString format:(NSString *)format
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDate *date = [self getDateFromDateString:dateString format:format];
    NSDateComponents *components = [calendar components:unit fromDate:date];
    NSArray *weakDayArray = [[NSArray alloc] initWithObjects:@"",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六", nil];
    NSInteger weekDay = components.weekday;
    NSString *weakDayStr = weakDayArray[weekDay];
    NSString *chineseDateStr = [NSString stringWithFormat:@"%ld年%02ld月%02ld日 %@",(long)components.year,(long)components.month,(long)components.day,weakDayStr];
    return chineseDateStr;
}
+ (NSDateComponents *)getDeltaDateToDateString:(NSString *)dateString format:(NSString *)format
{
    NSDate *toDate = [self getDateFromDateString:dateString format:format];
    NSDate *fromday = [NSDate date];//得到当前时间
    //用来得到具体的时差
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *deltaDate = [cal components:unitFlags fromDate:fromday toDate:toDate options:0];
    return deltaDate;
}
+ (NSDateComponents *)getDeltaDateToTimestampg:(long long)timestamp
{
    NSDate *toDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSDate *fromday = [NSDate date];//得到当前时间
    //用来得到具体的时差
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *deltaDate = [cal components:unitFlags fromDate:fromday toDate:toDate options:0];
    return deltaDate;
}
+ (NSDateComponents *)getDeltaDateFromDateString:(NSString *)fromDateString fromFormat:(NSString *)fromFormat toDateString:(NSString *)toDateString ToFormat:(NSString *)toFormat
{
    NSDate *toDate = [self getDateFromDateString:toDateString format:toFormat];
    NSDate *fromday = [self getDateFromDateString:fromDateString format:fromFormat];
    
    //用来得到具体的时差
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *deltaDate = [cal components:unitFlags fromDate:fromday toDate:toDate options:0];
    return deltaDate;
}
+ (NSDateComponents *)getDeltaDateFromTimestamp:(long long)formTimestamp fromFormat:(NSString *)fromFormat toTimestamp:(long long)toTimestamp ToFormat:(NSString *)toFormat
{
    NSDate *toDate = [self getTimeDateByTimestamp:toTimestamp format:toFormat];
    NSDate *fromday = [self getTimeDateByTimestamp:formTimestamp format:fromFormat];
    
    //用来得到具体的时差
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *deltaDate = [cal components:unitFlags fromDate:fromday toDate:toDate options:0];
    return deltaDate;
}
+ (NSDate *)getDateFromDateString:(NSString *)dateString format:(NSString *)format
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = format;
    NSDate *date = [fmt dateFromString:dateString];
    if(!dateString)
    {
        date = [NSDate date];
    }
    return date;
}
+ (NSDateComponents *)getDateComponentsBySeconds:(NSInteger)seconds
{
    NSDateComponents * deltaDate = [[NSDateComponents alloc]init];
    deltaDate.day = seconds / (24 * 60 * 60);
    deltaDate.hour = (seconds / (60 * 60)) % 24;
    deltaDate.minute = (seconds / 60) % 60;
    deltaDate.second = seconds % 60;
    return deltaDate;
}
+ (NSString *)getWeekFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:date];
    NSArray *weakDayArray = @[@"",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    NSInteger weekDay = components.weekday;
    NSString *weekStr = weakDayArray[weekDay];
    return  weekStr;
}

@end
