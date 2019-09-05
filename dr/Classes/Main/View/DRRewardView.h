//
//  DRRewardView.h
//  dr
//
//  Created by dahe on 2019/9/5.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRRewardView : UIView

- (instancetype)initWithFrame:(CGRect)frame drawUrl:(NSString *)drawUrl;

@property (nonatomic, strong) UINavigationController *owerViewController;

@end

NS_ASSUME_NONNULL_END
