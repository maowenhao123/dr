//
//  UIImage+DR.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DR)

/**
 *  返回一张自由拉伸的图片
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;
/**
 *  返回一张给定颜色和大小的图片
 */
+ (UIImage *)ImageFromColor:(UIColor *)color WithRect:(CGRect)rect;

- (UIImage *)fixOrientation;

@end
