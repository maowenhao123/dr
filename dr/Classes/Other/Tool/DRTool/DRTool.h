//
//  DRTool.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJRefresh.h"

@interface DRTool : NSObject
#pragma mark - 请求数据
/**
 获取digest
 */
+ (NSString *)getDigestByBodyDic:(NSDictionary *)bodyDic;
/**
 * 图片base64编码
 */
+ (NSString *)stringByimageBase64WithImage:(UIImage *)image;
#pragma mark - 刷新
/*
 设置下拉刷新数据
 */
+ (void)setRefreshHeaderData:(MJRefreshHeader *)header;
/*
 设置下拉刷新gif图
 */
+ (void)setRefreshHeaderGif:(MJRefreshHeader *)header;
/*
 设置上拉加载数据
 */
+ (void)setRefreshFooterData:(MJRefreshFooter *)footer;
#pragma mark - 无数据
/*
 字符串，无数据
 */
+ (NSString *)getString:(NSString *)string;
/*
 数字，无数据
 */
+ (NSNumber *)getNumber:(NSNumber *)number;
#pragma mark - 推送
/**
 登录环信账号
 */
+ (void)loginImAccount;
#pragma mark - json操作
/**
 *  把格式化的JSON格式的字符串转换成字典
 *
 *  @param jsonString jsonString JSON格式的字符串
 *
 *  @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/**
 *  带json格式的对象(字典)转化成json字符串
 *
 *  @param jsonObject json对象
 *
 *  @return 带json格式的字符串
 */
+ (NSString *)jsonStringWithObject:(id)jsonObject;
#pragma mark - 处理小数
/**
 *  自适应保留小数
 *
 *  @param f 要处理的数字
 *
 *  @return 处理后的字符串
 */
+ (NSString *)formatFloat:(double)f;
/**
 *  处理失真bug
 *
 *  @param num 要处理的数字
 *
 *  @return 处理后的数字
 */
+ (int)getHighPrecisionDouble:(double)num;
#pragma mark - 获取当前时间戳
/**
 *  返回当前时间戳
 */
+ (NSString *)getNowTimeTimestamp;
#pragma mark - 截取指定时间的视频缩略图
/**
 * 截取指定时间的视频缩略图
 *
 * @param videoURL 视频地址
 * @param timeBySecond 时间点，单位：s
 */
+ (UIImage *)getThumbnailImage:(NSString *)videoURL time:(int)timeBySecond;

#pragma mark - 获取视频时长
/**
 * 获取视频时长
 *
 * @param videoURL 视频地址
 */
+ (int)getVideoTimeWithSourcevideoURL:(NSURL *)videoURL;

#pragma mark - 压缩图片
/**
 * 压缩图片
 *
 * @param myimage 要压缩的图片
 */
+ (UIImage *)imageCompressionWithImage:(UIImage *)myimage;

#pragma mark - 获取底部安全区域
/**
 *  获取底部安全区域
 */
+ (CGFloat)getSafeAreaBottom;

#pragma mark - 获取底部安全区域
/**
 *  是否显示折扣价格
 */
+ (BOOL)showDiscountPriceWithGoodModel:(DRGoodModel *)goodModel;

#pragma mark - 判断字符串中是否存在emoji
/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;

#pragma mark - 通过类名找view的subview
/**
 *  通过类名找view的subview
 */
+ (UIView *_Nullable)findViewWithClassName:(NSString *_Nullable)className inView:(UIView *_Nullable)view;

@end
