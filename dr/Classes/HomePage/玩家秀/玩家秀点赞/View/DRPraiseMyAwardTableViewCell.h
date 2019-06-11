//
//  DRPraiseMyAwardTableViewCell.h
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPraiseSectionModel.h"

@class DRPraiseMyAwardTableViewCell;
@protocol PraiseMyAwardTableViewCellDelegate <NSObject>

- (void)praiseMyAwardTableViewCell:(DRPraiseMyAwardTableViewCell *)cell awardButtonDidClick:(UIButton *)button;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DRPraiseMyAwardTableViewCell : UITableViewCell

+ (DRPraiseMyAwardTableViewCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, assign) long long systemTime;
@property (nonatomic, strong) DRPraiseSectionModel * awardSectionModel;

/**
 协议
 */
@property (nonatomic, weak) id <PraiseMyAwardTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
