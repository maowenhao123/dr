//
//  DRAddSeckillGoodViewController.h
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddSeckillGoodDelegate <NSObject>

- (void)addSeckillGoodSuccess;//添加成功，返回上一页吗刷新数据

@end

@interface DRAddSeckillGoodViewController : DRBaseViewController

@property (nonatomic, weak) id<AddSeckillGoodDelegate> delegate;

@property (nonatomic, copy) NSString *activityId;

@end

NS_ASSUME_NONNULL_END
