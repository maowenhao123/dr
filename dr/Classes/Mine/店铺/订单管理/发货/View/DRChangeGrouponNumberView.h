//
//  DRChangeGrouponNumberView.h
//  dr
//
//  Created by 毛文豪 on 2017/11/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRChangeGrouponNumberView;
@protocol ChangeGrouponNumberViewDelegate <NSObject>

- (void)changeGrouponNumberView:(DRChangeGrouponNumberView *)changeGrouponNumberView number:(int)number;

@end

@interface DRChangeGrouponNumberView : UIView

/**
 协议
 */
@property (nonatomic, weak) id <ChangeGrouponNumberViewDelegate> delegate;

@end
