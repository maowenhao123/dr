//
//  DRManageSpecificationViewController.h
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ManageSpecificationDelegate <NSObject>

- (void)addSpecificationWithDataArray:(NSMutableArray *)dataArray;

@end

@interface DRManageSpecificationViewController : DRBaseViewController

@property (nonatomic, assign) id <ManageSpecificationDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

NS_ASSUME_NONNULL_END
