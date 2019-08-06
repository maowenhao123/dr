//
//  DRGoodHeaderFrameModel.h
//  dr
//
//  Created by 毛文豪 on 2018/1/23.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRGrouponModel.h"

@interface DRGoodHeaderFrameModel : NSObject

@property (nonatomic,assign) BOOL isGroupon;//团购页面来的
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic,strong) DRGrouponModel *grouponModel;
@property (nonatomic,copy) NSAttributedString *detailAttStr;
@property (nonatomic,copy) NSAttributedString *goodPriceAttStr;
@property (nonatomic, copy) NSString *mailTypeStr;

@property (nonatomic,assign) CGRect goodNameLabelF;
@property (nonatomic,assign) CGRect goodDetailLabelF;
@property (nonatomic,assign) CGRect goodPriceLabelF;
@property (nonatomic,assign) CGRect goodMailTypeLabelF;
@property (nonatomic,assign) CGRect goodSaleCountLabelF;
@property (nonatomic,assign) CGRect specificationViewF;
@property (nonatomic,assign) CGFloat GoodHeaderCellH;

@end
