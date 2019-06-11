//
//  EaseBubbleView+MessageGoodInfo.h
//  dr
//
//  Created by 毛文豪 on 2017/12/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "EaseBubbleView.h"

@interface EaseBubbleView (MessageGoodInfo)

- (void)updateShareMargin:(UIEdgeInsets)margin;
- (void)setUpShareBubbleView;
- (void)_setUpShareBubbleMarginConstraints;

@end
