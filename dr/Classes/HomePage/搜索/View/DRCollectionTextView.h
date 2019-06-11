//
//  DRCollectionTextView.h
//  dr
//
//  Created by 毛文豪 on 2017/3/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectionTextViewDelegate <NSObject>

- (void)collectionTextViewButtonDidClick:(UIButton *)button;

@end

@interface DRCollectionTextView : UIView

@property(nonatomic, weak)id <CollectionTextViewDelegate> delegate;

@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, strong) NSArray * texts;


- (CGFloat)getViewHeight;

@end
