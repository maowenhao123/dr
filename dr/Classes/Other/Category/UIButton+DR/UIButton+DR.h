//
//  UIButton+DR.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIButtonTitleWithImageAlignmentUp = 0,  // image is up, title is down
    UIButtonTitleWithImageAlignmentLeft,    // image is left, title is right
    UIButtonTitleWithImageAlignmentDown,    // image is down, title is up
    UIButtonTitleWithImageAlignmentRight    // image is right, title is left
} UIButtonTitleWithImageAlignment;

@interface UIButton (DR)

- (void)setButtonTitleWithImageAlignment:(UIButtonTitleWithImageAlignment)buttonTitleWithImageAlignment imgTextDistance:(CGFloat)imgTextDistance;

@end
