//
//  DRBillingScreeningViewController.h
//  dr
//
//  Created by 毛文豪 on 2018/5/21.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRSegementViewController.h"

@protocol BillingScreeningViewControllerDelegate <NSObject>

@optional;
- (void)billingScreeningByMonth:(NSString *)monthStr;
- (void)billingScreeningByBeginTimeStr:(NSString *)beginTimeStr endTimeStr:(NSString *)endTimeStr;

@end

@interface DRBillingScreeningViewController : DRSegementViewController

@property (nonatomic, copy) NSString *monthStr;
@property (nonatomic, copy) NSString *beginTimeStr;
@property (nonatomic, copy) NSString *endTimeStr;

@property (nonatomic, weak) id<BillingScreeningViewControllerDelegate> delegate;

@end
