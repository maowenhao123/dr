//
//  DRRedPacketView.h
//  dr
//
//  Created by 毛文豪 on 2018/2/2.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRRedPacketView : UIView

- (instancetype)initWithFrame:(CGRect)frame viewController:(UINavigationController *)viewController;

@property (nonatomic,assign) double price;
@property (nonatomic,copy) NSString *rewardId;

@end
