//
//  UILabel+DR.h
//  dr
//
//  Created by 毛文豪 on 2017/7/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextModel : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, assign) NSRange range;

@end

@interface UILabel (DR)

///是否显示点击效果，默认是打开
@property (nonatomic, assign) BOOL isShowTagEffect;

///TagArray  点击的字符串数组
- (void)onTapRangeActionWithString:(NSArray <NSString *> *)TagArray tapClicked:(void (^) (NSString *string , NSRange range , NSInteger index))tapClick;


@end
