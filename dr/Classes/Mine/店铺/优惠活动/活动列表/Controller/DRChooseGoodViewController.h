//
//  DRChooseGoodViewController.h
//  dr
//
//  Created by dahe on 2019/11/4.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChooseGoodViewControllerDelegate <NSObject>

- (void)ChooseGoodViewControllerChooseGoodModel:(DRGoodModel *)goodModel;

@end

@interface DRChooseGoodViewController : DRBaseViewController

/**
 协议
 */
@property (nonatomic, weak) id <ChooseGoodViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
