//
//  NSString+DR.h
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DR)

/**
 * md5加密
 */
- (NSString *)md5HexDigest;
/**
 * url编码
 */
- (NSString *)URLEncodedString;
/**
 * url解码
 */
- (NSString*)URLDecodedString;
/**
 *
 *  @param font    字体大小
 *
 *  @return 返回文字所占用的label宽高
 */
- (CGSize)sizeWithLabelFont:(UIFont *)font;
/**
 *
 *  @param font    字体大小
 *  @param maxSize 文字受限区域
 *
 *  @return 返回文字所占用的label宽高
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
