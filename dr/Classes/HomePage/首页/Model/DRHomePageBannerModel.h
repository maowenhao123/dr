//
//  DRHomePageBannerModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRHomePageBannerModel : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, copy) NSString *image;//图片
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, copy) NSString *url;
/*
 type:1 调转到一个webview，展示页面，页面地址为data数据就是一个url地址
 type:2 跳转到某商品 data为商品id
 type:3 跳转到一个activity，根据data值预先定义跳转到哪个页面，如data为1 调转到开店 ，data 为2 跳转到 注册（前端自定义）
 type:4 跳转到一个商品分类列表  data为分类id
 */
@end
