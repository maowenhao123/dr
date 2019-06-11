//
//  DRShowSectionHeaderView.h
//  dr
//
//  Created by 毛文豪 on 2018/12/13.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRShowModel.h"

@class DRShowSectionHeaderView;
@protocol ShowHeaderDelegate <NSObject>

@optional
- (void)showHeaderViewShowDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView;
- (void)showHeaderViewShowImageDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView imageView:(UIImageView *)imageView;
- (void)showHeaderViewPraiseDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView;
- (void)showHeaderViewCommentDidClickWithHeaderView:(DRShowSectionHeaderView *)headerView;

@end

@interface DRShowSectionHeaderView : UITableViewHeaderFooterView

+ (DRShowSectionHeaderView *)headerViewWithTableView:(UITableView *)talbeView;

@property (nonatomic, strong) NSMutableArray * imageViews;

@property (nonatomic, strong) DRShowModel * model;

/**
 协议
 */
@property (nonatomic, weak) id <ShowHeaderDelegate> delegate;

@end
