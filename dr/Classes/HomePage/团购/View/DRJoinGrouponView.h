//
//  DRJoinGrouponView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/11.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRJoinGrouponView;
@protocol JoinGrouponViewDelegate <NSObject>

- (void)JoinGrouponView:(DRJoinGrouponView *)joinGrouponView selectedNumber:(int)number;

@end

@interface DRJoinGrouponView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel plusCount:(int)plusCount payCount:(int)payCount successCount:(int)successCount;
/**
 协议
 */
@property (nonatomic, weak) id <JoinGrouponViewDelegate> delegate;

@end
