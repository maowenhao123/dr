//
//  DRPraiseListView.h
//  dr
//
//  Created by 毛文豪 on 2018/12/18.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPraiseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseListView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(int)type;

- (void)getPraiseData;

@property (nonatomic, strong) NSArray *praiseList;
@property (nonatomic, assign) int type;

@end

NS_ASSUME_NONNULL_END
