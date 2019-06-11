//
//  DRPraiseGoodAwardCollectionViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/12/25.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPraiseGoodAwardModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseGoodAwardCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DRPraiseGoodAwardModel *goodAwardModel;
@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, strong) NSNumber *type;

@end

NS_ASSUME_NONNULL_END
