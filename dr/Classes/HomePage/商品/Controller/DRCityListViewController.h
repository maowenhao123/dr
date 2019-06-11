//
//  DRCityListViewController.h
//  dr
//
//  Created by 毛文豪 on 2018/8/29.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBaseViewController.h"

@protocol DRCityListViewControllerDelegate <NSObject>

- (void)cityListViewControllerChooseAddress:(NSString *)address;

@end

@interface DRCityListViewController : DRBaseViewController

@property (nonatomic, copy) NSString *currentCityName;

/**
 协议
 */
@property (nonatomic, weak) id <DRCityListViewControllerDelegate> delegate;

@end
