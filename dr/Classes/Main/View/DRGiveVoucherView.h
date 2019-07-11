//
//  DRGiveVoucherView.h
//  dr
//
//  Created by 毛文豪 on 2018/9/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRVoucherModel.h"

@interface DRGiveVoucherView : UIView

- (instancetype)initWithFrame:(CGRect)frame redPacketList:(NSArray *)redPacketList;

@property (nonatomic, strong) UINavigationController *owerViewController;

@end

