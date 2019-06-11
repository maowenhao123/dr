//
//  DRPraiseListHeaderFooterView.h
//  dr
//
//  Created by 毛文豪 on 2019/1/7.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPraiseSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseListHeaderFooterView : UITableViewHeaderFooterView

+ (DRPraiseListHeaderFooterView *)headerViewWithTableView:(UITableView *)talbeView;

@property (nonatomic, strong) DRPraiseSectionModel *praiseSectionModel;

@end

NS_ASSUME_NONNULL_END
