//
//  DRAddBankCardViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@protocol AddBankCardDelegate <NSObject>

- (void)addBankSuccess;//添加银行卡成功，返回上一页吗刷新数据

@end

@interface DRAddBankCardViewController : DRBaseViewController

@property (nonatomic, weak) id<AddBankCardDelegate> delegate;

@end
