//
//  DRAddAddressViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/4/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import "DRAddressModel.h"

@protocol AddAddressDelegate <NSObject>

@optional;
- (void)addAddressSuccess;//添加银行卡成功，返回上一页吗刷新数据

@end

@interface DRAddAddressViewController : DRBaseViewController

@property (nonatomic, strong) DRAddressModel * addressModel;

@property (nonatomic, weak) id<AddAddressDelegate> delegate;

@end
