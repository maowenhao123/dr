//
//  DRTextView.h
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRTextView : UITextView

@property(nonatomic,copy) NSString *myPlaceholder;  //文字
@property(nonatomic,strong) UIColor *myPlaceholderColor; //文字颜色

@property (nonatomic, assign) NSInteger maxLimitNums;//最大字数
@property (nonatomic, weak) UIColor *maxLimitNumColor;

@end
