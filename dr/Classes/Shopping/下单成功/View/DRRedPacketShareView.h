//
//  DRRedPacketShareView.h
//  dr
//
//  Created by 毛文豪 on 2018/2/5.
//  Copyright © 2018年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMSocialCore/UMSocialCore.h>

typedef void (^ShareChoicePlatformTypBlock)(UMSocialPlatformType platformType);

@interface DRRedPacketShareView : UIView

@property (copy, nonatomic)ShareChoicePlatformTypBlock block;

- (void)show;

- (void)hide;

@end
