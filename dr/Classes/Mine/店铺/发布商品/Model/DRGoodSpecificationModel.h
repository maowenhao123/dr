//
//  DRGoodSpecificationModel.h
//  dr
//
//  Created by 毛文豪 on 2017/8/21.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRGoodSpecificationModel : NSObject

@property (nonatomic,assign) NSInteger index;//序号
@property (nonatomic,copy) NSString *name;//规格名称
@property (nonatomic,copy) NSString *price;//价格
@property (nonatomic,copy) NSString *plusCount;//库存数量
@property (nonatomic,strong) UIImage *pic;//图片
@property (nonatomic,copy) NSString *picUrl;

@end
