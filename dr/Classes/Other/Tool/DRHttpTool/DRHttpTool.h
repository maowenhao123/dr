//
//  DRHttpTool.h
//  dr
//
//  Created by 毛文豪 on 2017/4/12.
//  Copyright © 2017年 JG. All rights reserved.
//

////正式环境
//#define baseUrl @"http://www.esodar.com"
//#define baseH5Url  @"http://index.esodar.com"
//#define baseGoodShareUrl  @"http://wx.esodar.com"

//测试环境
#define baseUrl @"http://test.esodar.com"
#define baseH5Url  @"http://testindex.esodar.com"
#define baseGoodShareUrl  @"http://testwx.esodar.com"

#define mcpUrl [NSString stringWithFormat:@"%@/jshop/api/service", baseUrl]
#define smallPicUrl @""

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface DRHttpTool : NSObject

+ (DRHttpTool *)shareInstance;

/**
 *  发送一个POST请求
 *
 *  @param target  控制器
 *  @param headDic  请求参数
 *  @param bodyDic  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
- (void)postWithTarget:(UIViewController *)target headDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
/**
 *  发送一个POST请求
 *
 *  @param headDic  请求参数
 *  @param bodyDic  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
- (void)postWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

#pragma mark - 图片上传
+ (void)uploadWithImage:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent;
#pragma mark - 视频上传
+ (void)upFileWithVideo:(NSURL *)videoURL Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent;

@end
