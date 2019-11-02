//
//  DRHttpTool.m
//  dr
//
//  Created by 毛文豪 on 2017/4/12.
//  Copyright © 2017年 JG. All rights reserved.
//
#define requestTimeoutInterval 30

#import "DRHttpTool.h"
#import "AFHTTPSessionManager.h"
#import "JSON.h"
#import "UIViewController+DRNoNetController.h"

@implementation DRHttpTool

+ (DRHttpTool *)shareInstance
{
    static DRHttpTool *shareInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareInstance = [[[self class] alloc] init];
    });
    return shareInstance;
}
- (void)postWithTarget:(UIViewController *)target headDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic success:(void (^)(id json))success failure:(void (^)(NSError *error))failure
{
//    if ([self checkNetState]) {//有网的时候去请求数据
        [target hiddenNonetWork];
        [self postWithHeadDic:headDic bodyDic:bodyDic success:success failure:failure];
//    }else{//没网时显示
//        [target showNonetWork];
//        [MBProgressHUD hideHUDForView:target.view animated:YES];
//    }

}
/**
 *  请求数据
 */
- (void)postWithHeadDic:(NSDictionary *)headDic bodyDic:(NSDictionary *)bodyDic  success:(void (^)(id json))success failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *headDic_mu = [NSMutableDictionary dictionaryWithDictionary:headDic];
    [headDic_mu setObject:@"IOS" forKey:@"client"];
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [headDic_mu setObject:currentVersion forKey:@"version"];
    
    // 参数
    id headJson = [headDic_mu JSONFragment];
    id bodyJson = [bodyDic JSONFragment];
    //网址
    NSURL *url = [NSURL URLWithString:mcpUrl];
    //设置NSMutableURLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置超时时间
    request.timeoutInterval = 30;
    //设置请求方式
    request.HTTPMethod = @"POST";
    //设置参数
    NSString * head_utf8 = [[NSString stringWithFormat:@"%@",headJson] URLEncodedString];
    NSString * body_utf8 = [[NSString stringWithFormat:@"%@",bodyJson] URLEncodedString];
    
    NSString * HTTPBodyStr = [NSString stringWithFormat:@"head=%@&body=%@", head_utf8, body_utf8];
    request.HTTPBody = [HTTPBodyStr dataUsingEncoding:NSUTF8StringEncoding];
    //创建一个session对象,用来进行post请求
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //建立任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(),^{//主线程
            if (!error) {
                //解析
                NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
                mDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                success(mDict);
            }else
            {
                failure(error);
            }
        });
    }];
    //启动任务
    [task resume];
}

+ (void)uploadWithImage:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent
{
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:KEY_WINDOW animated:YES];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;//圆环作为进度条
    HUD.label.text = [NSString stringWithFormat:@"%ld/%ld图片上传中....", currentIndex, totalCount];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/jshop/file/upload", baseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData * data = UIImageJPEGRepresentation(image, 1.0);
        
        CGFloat dataKBytes = data.length/1000.0;
        CGFloat maxQuality = 0.9f;
        CGFloat lastData = dataKBytes;
        
        while (dataKBytes > 300 && maxQuality > 0.01f) {
            maxQuality = maxQuality - 0.01f;
            data = UIImageJPEGRepresentation(image, maxQuality);
            dataKBytes = data.length / 1000.0;
            if (lastData == dataKBytes) {
                break;
            }else{
                lastData = dataKBytes;
            }
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];

        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        percent(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = uploadProgress.fractionCompleted;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(responseObject);
        [HUD hideAnimated:YES];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
        [HUD hideAnimated:YES];
    }];
}

//视频上传
+ (void)upFileWithVideo:(NSURL *)videoURL Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:KEY_WINDOW animated:YES];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;//圆环作为进度条
    HUD.label.text = @"视频上传中....";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@/jshop/file/videoUpload", baseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[formatter stringFromDate:[NSDate date]]];
        NSData *data = [[NSData alloc]initWithContentsOfURL:videoURL];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@".mp4"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        percent(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = uploadProgress.fractionCompleted;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success (responseObject);
        [HUD hideAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure (error);
        [HUD hideAnimated:YES];
        
    }];
}


#pragma mark - 网络变化
/**
 *  判断网络状态
 *
 *  @return 返回状态 YES 为有网 NO 为没有网
 */
- (BOOL)checkNetState
{
    /*
     AFNetworkReachabilityStatusUnknown          = -1,
     AFNetworkReachabilityStatusNotReachable     = 0,
     AFNetworkReachabilityStatusReachableViaWWAN = 1,
     AFNetworkReachabilityStatusReachableViaWiFi = 2,
     */
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    DRLog(@"reachable:%d", [AFNetworkReachabilityManager sharedManager].isReachable);
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

@end
