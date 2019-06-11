//
//  DRStartGrouponView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRStartGrouponView;
@protocol StartGrouponViewDelegate <NSObject>

- (void)startGrouponView:(DRStartGrouponView *)startGrouponView selectedNumber:(int)number price:(float)price;

@end

@interface DRStartGrouponView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel successCount:(int)successCount;

/**
 协议
 */
@property (nonatomic, weak) id <StartGrouponViewDelegate> delegate;

@end
