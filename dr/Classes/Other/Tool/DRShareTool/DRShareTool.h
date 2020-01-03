//
//  DRShareTool.h
//  dr
//
//  Created by 毛文豪 on 2017/11/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMSocialCore/UMSocialCore.h>
#import "DRShareView.h"

@interface DRShareTool : NSObject

/*
 分享团购商品
 */
+ (void)shareGrouponByGrouponId:(NSString *)grouponId;

/*
 分享普通商品
 */
+ (void)shareGrouponByGoodId:(NSString *)goodId;

/*
 分享店铺
 */
+ (void)shareGrouponByShopId:(NSString *)shopId;

/*
 分享养护知识
 */
+ (void)shareGrouponByMaintainDic:(NSDictionary *)maintainDic;

/*
 分享app
 */
+ (void)shareApp;

/*
 分享红包
 */
+ (void)shareRedPacketWithRewardUrl:(NSString *)rewardUrl amountMoney:(float)amountMoney;

/*
 分享玩家秀
 */
+ (void)shareShowWithShowId:(NSString *)showId userNickName:(NSString *)userNickName title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl;

/*
 分享
 */
+ (void)shareWithTitle:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrl image:(UIImage *)image platformType:(UMSocialPlatformType)platformType url:(NSString *)url;

@end
