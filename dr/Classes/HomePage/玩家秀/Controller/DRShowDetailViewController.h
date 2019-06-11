//
//  DRShowDetailViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/3/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import "DRShowModel.h"

@protocol ShowDetailDelegate <NSObject>

- (void)deleteShowSuccess;//删除成功，返回上一页吗刷新数据
- (void)praiseButtonDidClickArtId:(NSString *)artId index:(NSInteger)index;

@end

@interface DRShowDetailViewController : DRBaseViewController

@property (nonatomic, copy) NSString *showId;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isHomePage;

@property (nonatomic, weak) id<ShowDetailDelegate> delegate;

@end
