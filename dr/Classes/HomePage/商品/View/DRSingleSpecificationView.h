//
//  DRSingleSpecificationView.h
//  dr
//
//  Created by dahe on 2019/8/6.
//  Copyright © 2019 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SingleSpecificationViewDelegate <NSObject>

- (void)goodSelectedNumber:(int)number price:(float)price isBuy:(BOOL)isBuy specificationModel:(DRGoodSpecificationModel *)specificationModel;

@end

@interface DRSingleSpecificationView : UIView

- (instancetype)initWithFrame:(CGRect)frame goodModel:(DRGoodModel *)goodModel type:(int)type;
/**
 协议
 */
@property (nonatomic, weak) id <SingleSpecificationViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
