//
//  UITextField+DRTextFieldSelected.h
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (DRTextFieldSelected)

- (NSRange)selectedRange;
- (void)setSelectedRange:(NSRange) range;

@end
