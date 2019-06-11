//
//  DRManageAddressViewController.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import "DRAddressModel.h"

@protocol ManageAddressViewControllerDelegate <NSObject>

@optional
- (void)manageAddressViewControllerSelectedAddressModel:(DRAddressModel *)addressModel;

@end

@interface DRManageAddressViewController : DRBaseViewController

@property (nonatomic, weak) id <ManageAddressViewControllerDelegate> delegate;

@end
