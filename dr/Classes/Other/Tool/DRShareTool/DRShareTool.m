//
//  DRShareTool.m
//  dr
//
//  Created by 毛文豪 on 2017/11/28.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShareTool.h"
#import "DRGrouponModel.h"
#import "DRShareView.h"
#import "DRRedPacketShareView.h"

static NSDictionary *platformDic;

@implementation DRShareTool

#pragma mark - 分享团购商品
+ (void)shareGrouponByGrouponId:(NSString *)grouponId
{
    NSDictionary *bodyDic = @{
        @"id":grouponId,
    };
    
    NSDictionary *headDic = @{
        @"cmd":@"S18",
    };
    [MBProgressHUD showMessage:@"请稍后"];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUD];
        if (SUCCESS) {
            DRGrouponModel *grouponModel = [DRGrouponModel mj_objectWithKeyValues:json[@"group"]];
            [self shareGrouponByGrouponModel:grouponModel];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUD];
    }];
}

+ (void)shareGrouponByGrouponModel:(DRGrouponModel *)grouponModel
{
    DRShareView * shareView = [[DRShareView alloc]init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareWithTitle:[NSString stringWithFormat:@"【拼团啦】%@¥%@，%@个起团 - 已团%@个，手慢无！", grouponModel.goods.name, [DRTool formatFloat:[grouponModel.goods.price floatValue] / 100], grouponModel.successCount, grouponModel.payCount] description:grouponModel.goods.description_ imageUrl:[NSString stringWithFormat:@"%@%@", baseUrl, grouponModel.goods.spreadPics] image:nil platformType:platformType url:[NSString stringWithFormat:@"%@/#/goodsdetail/%@/%@/%d", baseGoodShareUrl, grouponModel.goods.id, grouponModel.goods.sellType, 1]];
    };
}

#pragma mark - 分享普通商品
+ (void)shareGrouponByGoodId:(NSString *)goodId
{
    NSDictionary *bodyDic = @{
        @"id":goodId,
    };
    
    NSDictionary *headDic = @{
        @"cmd":@"B08",
    };
    [MBProgressHUD showMessage:@"请稍后"];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUD];
        if (SUCCESS) {
            DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:json[@"goods"]];
            [self shareGoodByGoodModel:goodModel];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        DRLog(@"error:%@",error);
    }];
}

+ (void)shareGoodByGoodModel:(DRGoodModel *)goodModel
{
    DRShareView * shareView = [[DRShareView alloc]init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareWithTitle:[NSString stringWithFormat:@"【吾花肉】%@¥%@", goodModel.name, [DRTool formatFloat:[goodModel.price floatValue] / 100]] description:goodModel.description_ imageUrl:[NSString stringWithFormat:@"%@%@", baseUrl, goodModel.spreadPics] image:nil platformType:platformType url:[NSString stringWithFormat:@"%@/#/goodsdetail/%@/%@/%d", baseGoodShareUrl, goodModel.id, goodModel.sellType, goodModel.isGroup]];
    };
}

#pragma mark - 分享店铺
+ (void)shareGrouponByShopId:(NSString *)shopId
{
    NSDictionary *bodyDic = @{
        @"storeId":shopId,
    };
    
    NSDictionary *headDic = @{
        @"cmd":@"B01",
    };
    [MBProgressHUD showMessage:@"请稍后"];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUD];
        if (SUCCESS) {
            DRShopModel * shopModel = [DRShopModel mj_objectWithKeyValues:json];
            [self shareShopByShopModel:shopModel];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUD];
    }];
}

+ (void)shareShopByShopModel:(DRShopModel *)shopModel
{
    DRShareView * shareView = [[DRShareView alloc] init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareWithTitle:@"买卖多肉就上吾花肉APP" description:@"向您推荐一个多肉店铺，物美价廉，值得收藏哦~" imageUrl:nil image:[UIImage imageNamed:@"share_logo"] platformType:platformType url:[NSString stringWithFormat:@"http://wx.esodar.com/#/storedetail/%@", shopModel.id]];
    };
}

#pragma mark - 分享养护知识
+ (void)shareGrouponByMaintainDic:(NSDictionary *)maintainDic
{
    DRShareView * shareView = [[DRShareView alloc] init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        NSString * description = maintainDic[@"description"];
        if (DRStringIsEmpty(description)) {
            description = @"养护详情";
        }
        [self shareWithTitle:maintainDic[@"title"] description:description imageUrl:[NSString stringWithFormat:@"%@%@%@",baseUrl, maintainDic[@"image"], smallPicUrl] image:nil platformType:platformType url:[NSString stringWithFormat:@"%@/jshop/share/art/%@", baseUrl, maintainDic[@"id"]]];
    };
}

#pragma mark - 分享app
+ (void)shareApp
{
    DRShareView * shareView = [[DRShareView alloc] init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareWithTitle:@"买多肉就上吾花肉" description:@"国内最大最专业的多肉植物及周边商品销售平台，支持零售、批发、拼团" imageUrl:nil image:[UIImage imageNamed:@"share_logo"] platformType:platformType url:[NSString stringWithFormat:@"%@/static/download.html", baseUrl]];
    };
}

#pragma mark - 分享红包
+ (void)shareRedPacketWithRewardUrl:(NSString *)rewardUrl amountMoney:(float)amountMoney
{
    DRRedPacketShareView * shareView = [[DRRedPacketShareView alloc] init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareWithTitle:@"【吾花肉】拼手气，抢红包" description:[NSString stringWithFormat:@"%@元多肉红包等你来抢，手快有，手慢无", [DRTool formatFloat:amountMoney]] imageUrl:nil image:[UIImage imageNamed:@"order_red_packet_share_icon"] platformType:platformType url:rewardUrl];
    };
}

#pragma mark - 分享玩家秀
+ (void)shareShowWithShowId:(NSString *)showId userNickName:(NSString *)userNickName title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl
{
    NSDictionary *bodyDic = @{
        @"id":showId
    };
    
    NSDictionary *headDic = @{
        @"digest":[DRTool getDigestByBodyDic:bodyDic],
        @"cmd":@"G11",
        @"userId":UserId,
    };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRShareView * shareView = [[DRShareView alloc] init];
            [shareView show];
            shareView.block = ^(UMSocialPlatformType platformType){//选择平台
                if (platformType == UMSocialPlatformType_WechatTimeLine) {
                    [DRShareTool shareWithTitle:[NSString stringWithFormat:@"@%@发布了一篇花肉玩家秀，火速围观！", userNickName] description:[NSString stringWithFormat:@"%@\n%@", title, content] imageUrl:imageUrl image:nil platformType:platformType url:json[@"url"]];
                }else
                {
                    [DRShareTool shareWithTitle:[NSString stringWithFormat:@"@%@发布了一篇花肉玩家秀", userNickName] description:[NSString stringWithFormat:@"%@\n%@", title, content] imageUrl:imageUrl image:nil platformType:platformType url:json[@"url"]];
                }
            };
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

+ (void)shareWithTitle:(NSString *)title description:(NSString *)description imageUrl:(NSString *)imageUrl image:(UIImage *)image platformType:(UMSocialPlatformType)platformType url:(NSString *)url
{
    UIImage * shareImage;
    if (!DRStringIsEmpty(imageUrl) && [imageUrl containsString:@"http"]) {
        [MBProgressHUD showMessage:@"请稍后"];
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        shareImage = [UIImage imageWithData:imageData];
        [MBProgressHUD hideHUD];
    }else
    {
        shareImage = image;
    }
    if (!shareImage) {
        shareImage = [UIImage imageNamed:@"share_logo"];
    }
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:description thumImage:shareImage];
    shareObject.webpageUrl = url;
    
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
        if (error) {
            NSInteger errorCode = error.code;
            if (errorCode == 2003) {
                [MBProgressHUD showError:@"分享失败"];
            }else if (errorCode == 2008)
            {
                [MBProgressHUD showError:@"应用未安装"];
            }else if (errorCode == 2010)
            {
                [MBProgressHUD showError:@"网络异常"];
            }
        }
    }];
}

@end
