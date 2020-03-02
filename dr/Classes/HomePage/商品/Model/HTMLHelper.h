//
//  HTMLHelper.h
//  dr
//
//  Created by dahe on 2020/1/13.
//  Copyright © 2020 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTMLHelper : NSObject

/**
 解析原始的 html string 为 NSAttributedString

 @param originHtml html标签 string
 @return NSAttributedString
 */
+ (NSAttributedString *)attributedTextFromHTML:(NSString *)originHtml;

@end

NS_ASSUME_NONNULL_END
