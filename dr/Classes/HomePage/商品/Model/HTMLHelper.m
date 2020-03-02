//
//  HTMLHelper.m
//  dr
//
//  Created by dahe on 2020/1/13.
//  Copyright © 2020 JG. All rights reserved.
//

#import "HTMLHelper.h"
@interface HTMLHelper ()

@end

@implementation HTMLHelper

//获取webView中的所有图片URL
- (NSArray *)getImageurlFromHtml:(NSMutableAttributedString *) webString {
    NSMutableArray *imageurlArray = [[NSMutableArray alloc] init];
    NSMutableArray *ranges = [[NSMutableArray alloc] init];
    if (webString.length==0) {
        return nil;
    }
    NSString *webStr  = [webString.string copy];

    //标签匹配
    NSString *parten = @"<img(.*?)>";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];

    NSArray* match = [reg matchesInString:webStr options:0 range:NSMakeRange(0, [webString length] - 1)];

    for (NSTextCheckingResult * result in match) {

        //过去数组中的标签
        NSRange range = [result range];
        NSString *rangeString = NSStringFromRange(range);
        NSLog(@"-------add item:%@", rangeString);
        [ranges addObject:rangeString];
        NSString * subString = [webStr substringWithRange:range];


        //从图片中的标签中提取ImageURL
        NSRegularExpression *subReg = [NSRegularExpression regularExpressionWithPattern:@"http://(.*?)\"" options:0 error:NULL];
        NSArray* match = [subReg matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];

        NSRegularExpression *subRegOne = [NSRegularExpression regularExpressionWithPattern:@"https://(.*?)\"" options:0 error:NULL];
        NSArray *matchOne = [subRegOne matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
        NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
        if (match.count > 0) {
            [tmpItems addObjectsFromArray:match];
        }
        if (matchOne.count > 0) {
            [tmpItems addObjectsFromArray:matchOne];

        }
        if (tmpItems.count > 0) {
            NSTextCheckingResult * subRes = tmpItems[0];
            NSRange subRange = [subRes range];
            subRange.length = subRange.length -1;
            NSString * imagekUrl = [subString substringWithRange:subRange];

            //将提取出的图片URL添加到图片数组中
            [imageurlArray addObject:imagekUrl];
        }
    }
    return imageurlArray;
}

+ (NSAttributedString *)attributedTextFromHTML:(NSString *)html {
    if (html.length == 0 ) {
        return [[NSAttributedString alloc] init];
    }
    NSMutableString *mutableHtml = [html mutableCopy];
    NSMutableArray<NSString *> *subStrings = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *imageurlArray = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *ranges = [[NSMutableArray alloc] init];

    //标签匹配
    NSString *parten = @"<img(.*?)>";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];

    NSArray* match = [reg matchesInString:html options:0 range:NSMakeRange(0, [html length] - 1)];
    if (match.count > 0) {
        for (NSTextCheckingResult *result in match) {
            //过去数组中的标签
            NSRange range = [result range];
            NSString *rangeString = NSStringFromRange(range);
            NSLog(@"-------add item:%@", rangeString);
            [ranges addObject:rangeString];
            NSString * subString = [html substringWithRange:range];

            //从图片中的标签中提取ImageURL
            NSRegularExpression *subReg = [NSRegularExpression regularExpressionWithPattern:@"http://(.*?)\"" options:0 error:NULL];
            NSArray* match = [subReg matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
            NSRegularExpression *subRegOne = [NSRegularExpression regularExpressionWithPattern:@"https://(.*?)\"" options:0 error:NULL];
            NSArray *matchOne = [subRegOne matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
            NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
            if (match.count > 0) {
                [tmpItems addObjectsFromArray:match];
            }
            if (matchOne.count > 0) {
                [tmpItems addObjectsFromArray:matchOne];

            }
            if (tmpItems.count > 0) {
                NSTextCheckingResult * subRes = tmpItems[0];
                NSRange subRange = [subRes range];
                subRange.length = subRange.length -1;
                NSString * imagekUrl = [subString substringWithRange:subRange];

                //将提取出的图片URL添加到图片数组中
                [imageurlArray addObject:imagekUrl];
            }
        }
    }
    ///将 html 按图片分割，并加入数组
    NSLog(@"ranges:%@", ranges.description);
    NSLog(@"imgURLs:%@", imageurlArray.description);
    if (ranges.count > 0) {
        NSUInteger startIndex = html.length;
        NSUInteger length = 0;
        for ( int index = ranges.count - 1; index >= 0; index--) {
            NSLog(@"currentRange:%@", ranges[index]);
            NSLog(@"mutableHtml length:%ld", mutableHtml.length);
            NSRange tmpRange = NSRangeFromString(ranges[index]);
            startIndex = tmpRange.location + tmpRange.length;
            length = mutableHtml.length - startIndex;

            NSLog(@"start index:%ld", startIndex);

            if (startIndex < mutableHtml.length ) {
                NSRange subStringRange = NSMakeRange(startIndex, length);
                NSString *tmpString = [mutableHtml substringWithRange:subStringRange];
                if (subStrings.count == 0) {
                    [subStrings addObject:tmpString];
                } else {
                    [subStrings insertObject:tmpString atIndex:0];
                }
            }
            mutableHtml = [[mutableHtml substringToIndex:tmpRange.location] mutableCopy];
        }
        if (mutableHtml.length > 0) {
            if (subStrings.count == 0) {
                [subStrings addObject:mutableHtml];
            } else {
                [subStrings insertObject:mutableHtml atIndex:0];
            }
        }
    }

    NSMutableAttributedString *terminalString = [HTMLHelper attributedTextFrom:subStrings imgSrcs:imageurlArray];
    return [terminalString copy];
}


/**
 将数组中的字符串和图片资源重组为 AttributedString

 @param subStrings <#subStrings description#>
 @param imgURLs <#imgURLs description#>
 @return <#return value description#>
 */
+ (NSMutableAttributedString *)attributedTextFrom:(NSArray *)subStrings imgSrcs:(NSArray *)imgURLs {
    NSMutableAttributedString *string  = [[NSMutableAttributedString alloc] init];
    if (subStrings.count > 0) {
        for (int index = 0; index < subStrings.count; index++) {
            NSAttributedString *tmpString = [[NSMutableAttributedString alloc] initWithData:[subStrings[index] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
            [string appendAttributedString:tmpString];
            if (imgURLs.count > index) {

                NSTextAttachment *attach = [[NSTextAttachment alloc] init];

                NSString *imageUrlStr = imgURLs[index];

                NSURL *url = [NSURL URLWithString:imageUrlStr];

                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImage *image = [UIImage imageWithData:imageData];
                attach.image = image;

                CGSize size = CGSizeMake(screenWidth - 10, image.size.height / image.size.width * screenWidth);

                attach.bounds = CGRectMake(0, 0, size.width, size.height);

                NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];

                // 点击图片跳转到safari
                NSMutableAttributedString *maImageStr = [[NSMutableAttributedString alloc] initWithAttributedString:attachString];

                [maImageStr addAttribute:NSLinkAttributeName value:url.absoluteString range:NSMakeRange(0, maImageStr.length)];
                [string appendAttributedString:maImageStr];
            }
        }
    }
    return string;
}

@end
