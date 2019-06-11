//
//  DRBankCardModel.h
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRBankCardModel : NSObject

@property (nonatomic, copy) NSString * id;//id
@property (nonatomic, copy) NSString * bankName;//银行名字
@property (nonatomic, copy) NSString * cardNo;//银行卡号
@property (nonatomic, copy) NSString * name;//名字
@property (nonatomic, strong) NSNumber * defaultv;//是否是默认银行卡


//自定义
@property (nonatomic, assign) BOOL isSelected;//是否选中的

@end
