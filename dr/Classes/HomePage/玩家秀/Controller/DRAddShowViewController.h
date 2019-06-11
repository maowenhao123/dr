//
//  DRAddShowViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/4/5.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@protocol AddShowDelegate <NSObject>

- (void)addShowSuccess;//添加成功，返回上一页吗刷新数据

@end

@interface DRAddShowViewController : DRBaseViewController

@property (nonatomic, weak) id<AddShowDelegate> delegate;

@end
