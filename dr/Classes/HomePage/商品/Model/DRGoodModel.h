//
//  DRGoodModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRShopModel.h"
#import "DRGoodSpecificationModel.h"

@interface DRGoodModel : NSObject

@property (nonatomic, strong) NSNumber * agentPrice;
@property (nonatomic,copy) NSString *categoryId;
@property (nonatomic,copy) NSString *categoryName;
@property (nonatomic,strong) NSNumber *commentCount;
@property (nonatomic,copy) NSString *description_;
@property (nonatomic,strong) NSNumber *directMailCount;
@property (nonatomic,strong) NSNumber *focusCount;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSString *morePics;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *plusCount;
@property (nonatomic,strong) NSNumber *praiseCount;
@property (nonatomic,strong) NSNumber *price;
@property (nonatomic,strong) NSNumber *sellCount;
@property (nonatomic,strong) NSNumber *sellType;
@property (nonatomic,copy) NSString *spreadPics;
@property (nonatomic,assign) int isGroup;
@property (nonatomic,strong) NSNumber *groupPrice;
@property (nonatomic,strong) NSNumber *groupNumber;
@property (nonatomic,strong) NSNumber *status;
@property (nonatomic,strong) DRShopModel *store;
@property (nonatomic,copy) NSString *subjectId;
@property (nonatomic,copy) NSString *subjectName;
@property (nonatomic,copy) NSString *typeName;
@property (nonatomic,strong) NSArray *wholesaleRule;
@property (nonatomic,assign) long long createTime;
@property (nonatomic,strong) NSNumber *mailPrice;
@property (nonatomic,copy) NSString *mailType;//快递方式 1 包邮 2 肉币支付  3 快递到付
@property (nonatomic,copy) NSString *remark;//驳回原因
@property (nonatomic,assign) BOOL supportRefund;
@property (nonatomic,copy) NSString *detail;
@property (nonatomic,strong) NSArray *richTexts;
@property (nonatomic, copy) NSString *video;
@property (nonatomic, copy) NSString *videoTime;
@property (nonatomic,strong) NSNumber *discountPrice;
@property (nonatomic,strong) NSNumber *activityStock;
@property (nonatomic,assign) long long beginTime;
@property (nonatomic,assign) long long endTime;
@property (nonatomic,assign) long long systemTime;
@property (nonatomic,assign) long long dayBeginTime;
@property (nonatomic,assign) long long dayEndTime;
@property (nonatomic,copy) NSAttributedString *htmlAttStr;
@property (nonatomic,assign) CGFloat htmlLabelH;
@property (nonatomic,strong) NSArray <NSString *>*tags;
@property (nonatomic,strong) NSArray <DRGoodSpecificationModel *>*specifications;
//自定义
@property (nonatomic,assign) int type;//1:已上架 2:审核中 3:已驳回 4:已下架

@end
