//
//  DRTool.m
//  dr
//
//  Created by apple on 17/1/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRTool.h"
#import "JSON.h"
#import "GTMBase64.h"
#import <HyphenateLite/HyphenateLite.h>
#import <AVFoundation/AVFoundation.h>

@implementation DRTool

#pragma mark - 请求数据
+ (NSString *)getDigestByBodyDic:(NSDictionary *)bodyDic
{
    return [[NSString stringWithFormat:@"%@%@",[bodyDic JSONFragment],Token] md5HexDigest];
}
+ (NSString *)stringByimageBase64WithImage:(UIImage *)image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 0.5);
        mimeType = @"image/jpeg";
    }
    NSString * imageBase64 = [GTMBase64 stringByEncodingData:imageData];
    return imageBase64;
}
+ (BOOL)imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}
#pragma mark - 刷新
//设置下拉刷新数据
+ (void)setRefreshHeaderData:(MJRefreshHeader *)header
{
    if ([header isKindOfClass:[MJRefreshGifHeader class]]) {
        
    }
}
// 设置下拉刷新gif图
+ (void)setRefreshHeaderGif:(MJRefreshHeader *)header
{
    
}
// 设置上拉加载数据
+ (void)setRefreshFooterData:(MJRefreshFooter *)footer
{
    if ([footer isKindOfClass:[MJRefreshBackGifFooter class]]) {
        
    }
}
#pragma mark - 无数据
+ (NSString *)getString:(NSString *)string
{
    if (DRStringIsEmpty(string)) {
        string = @"";
    }
    return string;
}
+ (NSNumber *)getNumber:(NSNumber *)number
{
    if (number == nil) {
        number = @0;
    }
    return number;
}
#pragma mark - 推送
//登录环信账号
+ (void)loginImAccount
{
    if (!UserId) return;
    //异步登录
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * password = [[NSString stringWithFormat:@"%@0605030201", UserId] md5HexDigest];
        EMError *error = [[EMClient sharedClient] loginWithUsername:UserId password:password];
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        if (!error)
        {
            DRLog(@"登录成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hxLoginSuccess" object:nil];
            DRUser *user = [DRUserDefaultTool user];
            [[EMClient sharedClient] setApnsNickname:user.nickName];
            EMPushOptions *options = [[EMClient sharedClient] pushOptions];
            options.displayStyle = EMPushDisplayStyleMessageSummary;// 显示消息内容
            EMError *pushError = [[EMClient sharedClient] updatePushOptionsToServer];
            if(!pushError) {
                DRLog(@"更新成功");
            }else {
                DRLog(@"更新失败");
            }
        }else
        {
            DRLog(@"登录失败");
        }
    });
}

#pragma mark - json操作
//把格式化的JSON格式的字符串转换成字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//带json格式的对象(字典)转化成json字符串
+ (NSString *)jsonStringWithObject:(id)jsonObject
{
    // 将字典或者数组转化为JSON串
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    }else{
        return nil;
    }
}

#pragma mark - 处理小数
//自适应保留小数
+ (NSString *)formatFloat:(double)f
{
    if (fmod(f, 1)==0) {//如果是整数
        return [NSString stringWithFormat:@"%.0f",f];
    } else if (fmod(f*10, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.1f",f];
    } else {
        return [NSString stringWithFormat:@"%.2f",f];
    }
}

//处理失真bug
+ (int)getHighPrecisionDouble:(double)num
{
    int num_int = round(num * 100);
    return num_int;
}
#pragma mark - 获取当前时间戳
//获取当前时间戳（以毫秒为单位）
+ (NSString *)getNowTimeTimestamp
{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (long long)[datenow timeIntervalSince1970] * 1000];
    
    return timeSp;
}

#pragma mark - 截取指定时间的视频缩略图
+ (UIImage *)getThumbnailImage:(NSString *)videoURL time:(int)timeBySecond
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoURL] options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(timeBySecond, 60);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark - 获取视频时长
+ (int)getVideoTimeWithSourcevideoURL:(NSURL *)videoURL
{
    AVURLAsset * asset = [AVURLAsset assetWithURL:videoURL];
    CMTime time = [asset duration];
    int seconds = (int)(time.value/time.timescale);
    return seconds;
}

#pragma mark - 压缩图片
+ (UIImage *)imageCompressionWithImage:(UIImage *)myimage{
    myimage = [myimage fixOrientation];
    NSData *data = UIImageJPEGRepresentation(myimage, 1);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.3);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }
    }
    return [UIImage imageWithData:data];
}

#pragma mark - 获取底部安全区域
+ (CGFloat)getSafeAreaBottom
{
    if (@available(iOS 11.0, *)) {
        return KEY_WINDOW.safeAreaInsets.bottom;
    }
    return 0;
}

#pragma mark - 是否显示折扣价格
+ (BOOL)showDiscountPriceWithGoodModel:(DRGoodModel *)goodModel
{
    if ([goodModel.sellType intValue] == 1 && goodModel.systemTime < goodModel.dayEndTime && goodModel.systemTime > goodModel.beginTime && !DRObjectIsEmpty(goodModel.discountPrice) && !DRObjectIsEmpty(goodModel.activityStock)) {
        return YES;
    }
    return NO;
}

#pragma mark - 判断字符串中是否存在emoji
/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

#pragma mark - 通过类名找view的subview
+ (UIView *)findViewWithClassName:(NSString *)className inView:(UIView *)view
{
    Class specificView = NSClassFromString(className);
    if ([view isKindOfClass:specificView]) {
        return view;
    }
    
    if (view.subviews.count > 0) {
        for (UIView *subView in view.subviews) {
            UIView *targetView = [self findViewWithClassName:className inView:subView];
            if (targetView != nil) {
                return targetView;
            }
        }
    }
    return nil;
}


@end
