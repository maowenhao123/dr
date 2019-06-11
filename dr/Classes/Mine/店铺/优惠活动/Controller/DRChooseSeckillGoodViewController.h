//
//  DRChooseSeckillGoodViewController.h
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChooseSeckillGoodViewControllerDelegate <NSObject>

- (void)chooseSeckillGoodViewControllerChooseGoodModel:(DRGoodModel *)goodModel;

@end

@interface DRChooseSeckillGoodViewController : DRBaseViewController

/**
 协议
 */
@property (nonatomic, weak) id <ChooseSeckillGoodViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
