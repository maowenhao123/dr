//
//  DRWholesaleNumberView.h
//  dr
//
//  Created by 毛文豪 on 2017/5/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WholesaleNumberViewDelegate <NSObject>

- (void)goodSelectedNumber:(int)number price:(float)price isBuy:(BOOL)isBuy specificationModel:(DRGoodSpecificationModel *)specificationModel;

@end

@interface DRWholesaleNumberView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel type:(int)type;

/**
 协议
 */
@property (nonatomic, weak) id <WholesaleNumberViewDelegate> delegate;

@end
