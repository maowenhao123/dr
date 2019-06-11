//
//  DRGoodListViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@interface DRGoodListViewController : DRBaseViewController

@property (nonatomic, copy) NSString *shopId;//店铺Id，无此参数，查询全部
@property (nonatomic, copy) NSString *categoryId;//分类Id,无此参数，查询全部
@property (nonatomic, copy) NSString *isGroup;
@property (nonatomic,copy) NSString *subjectId;//科目分类 
@property (nonatomic,copy) NSString *type;//1 推荐商品，不传默认排序
@property (nonatomic,copy) NSString *sellType;
@property (nonatomic, copy) NSString *likeName;
@property (nonatomic,strong) NSArray *sorts;//筛选条件
@property (nonatomic, copy) NSString *minPrice;
@property (nonatomic, copy) NSString *maxPrice;

@end
