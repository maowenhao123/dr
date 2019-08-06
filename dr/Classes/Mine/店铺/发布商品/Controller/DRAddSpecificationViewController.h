//
//  DRAddSpecificationViewController.h
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import "DRGoodSpecificationModel.h"

NS_ASSUME_NONNULL_BEGIN
@class DRGoodSpecificationModel;

@protocol AddSpecificationDelegate <NSObject>

- (void)addSpecificationWithSpecificationModel:(DRGoodSpecificationModel *)specificationModel;
- (void)editSpecificationWithSpecificationModel:(DRGoodSpecificationModel *)specificationModel;

@end

@interface DRAddSpecificationViewController : DRBaseViewController

@property (nonatomic, assign) id <AddSpecificationDelegate> delegate;

@property (nonatomic,strong) DRGoodSpecificationModel *goodSpecificationModel;

@end

NS_ASSUME_NONNULL_END
