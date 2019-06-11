//
//  DRShareView.h
//  dr
//
//  Created by 毛文豪 on 2017/7/14.
//  Copyright © 2017年 JG. All rights reserved.
//r

#import <UIKit/UIKit.h>
#import <UMSocialCore/UMSocialCore.h>

typedef void (^ShareChoicePlatformTypBlock)(UMSocialPlatformType platformType);

@interface DRShareView : UIView

@property (copy, nonatomic)ShareChoicePlatformTypBlock block;

- (void)show;

- (void)hide;

@end
