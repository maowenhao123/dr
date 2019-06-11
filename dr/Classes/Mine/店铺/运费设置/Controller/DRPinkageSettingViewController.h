//
//  DRPinkageSettingViewController.h
//  dr
//
//  Created by 毛文豪 on 2018/4/16.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@protocol PinkageSettingDelegate <NSObject>

@optional;
- (void)pinkageSettingSuccessWithMoney:(NSNumber *)money;//添加成功，返回上一页吗刷新数据

@end

@interface DRPinkageSettingViewController : DRBaseViewController

@property (nonatomic, assign) NSNumber *ruleMoney;

@property (nonatomic, weak) id<PinkageSettingDelegate> delegate;

@end
