//
//  DRShareView.m
//  dr
//
//  Created by 毛文豪 on 2017/7/14.
//  Copyright © 2017年 JG. All rights reserved.
//
#define KWidth self.bounds.size.width
#define KHeight self.bounds.size.height

#import "DRShareView.h"
#import "UIButton+DR.h"

@interface DRShareView ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *platformTypeNames;

@end

@implementation DRShareView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChilds];
    }
    return self;
}

- (void)setupChilds
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, 70 + [DRTool getSafeAreaBottom])];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    
    //分享平台
    CGFloat platformTypeViewW = KWidth / self.platformTypeNames.count;
    CGFloat platformTypeViewH = contentView.height;
    for (NSString * platformTypeName in self.platformTypeNames) {
        NSInteger index = [self.platformTypeNames indexOfObject:platformTypeName];
        UIView * platformTypeView = [[UIView alloc]init];
        platformTypeView.frame = CGRectMake(platformTypeViewW * index, 0, platformTypeViewW, platformTypeViewH);
        platformTypeView.userInteractionEnabled = YES;
        platformTypeView.tag = index;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(platformTypeViewDidClick:)];
        [platformTypeView addGestureRecognizer:tap];
        [contentView addSubview:platformTypeView];
        
        //logo
        UIImageView * platformTypeLogo = [[UIImageView alloc]init];
        CGFloat platformTypeLogoWH = 35;
        CGFloat platformTypeLogoX = (platformTypeViewW - platformTypeLogoWH) / 2;
        CGFloat platformTypeLogoY = 10;
        platformTypeLogo.frame = CGRectMake(platformTypeLogoX, platformTypeLogoY, platformTypeLogoWH, platformTypeLogoWH);
        platformTypeLogo.image = [self getLogoByPlatformTypeName:platformTypeName];
        [platformTypeView addSubview:platformTypeLogo];
        
        //名称
        UILabel * platformTypeNameLabel = [[UILabel alloc]init];
        CGFloat platformTypeNameLabelY = CGRectGetMaxY(platformTypeLogo.frame) + 5;
        platformTypeNameLabel.frame = CGRectMake(0, platformTypeNameLabelY, platformTypeViewW, 15);
        platformTypeNameLabel.text = platformTypeName;
        platformTypeNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        platformTypeNameLabel.textColor = DRBlackTextColor;
        platformTypeNameLabel.textAlignment = NSTextAlignmentCenter;
        [platformTypeView addSubview:platformTypeNameLabel];
    }
}

//选择平台
- (void)platformTypeViewDidClick:(UITapGestureRecognizer *)tap
{
    UMSocialPlatformType platformType = [self getPlatformTypeByPlatformTypeName:self.platformTypeNames[tap.view.tag]];
    [self hide];
    if (self.block) {
        self.block(platformType);
    }
}
//显示
- (void)show{
    UIView *topView = [KEY_WINDOW.subviews firstObject];
    [topView addSubview:self];
    
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.contentView.y = screenHeight - self.contentView.height;
    }];
}
//隐藏
- (void)hide{
    [UIView animateWithDuration:DRAnimateDuration animations:^{
        self.alpha = 0;
        self.contentView.y = screenHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
//通过名称获取logo
- (UIImage *)getLogoByPlatformTypeName:(NSString *)platformTypeName
{
    UIImage * platformTypeLogo = [[UIImage alloc]init];
    if ([platformTypeName isEqualToString:@"微信"]) {
        platformTypeLogo = [UIImage imageNamed:@"icon_weixin_fenxiang"];
    }else if ([platformTypeName isEqualToString:@"朋友圈"])
    {
        platformTypeLogo = [UIImage imageNamed:@"icon_pengyouquan_fenxiang"];
    }else if ([platformTypeName isEqualToString:@"QQ"])
    {
        platformTypeLogo = [UIImage imageNamed:@"icon_qq_fenxiang"];
    }
    return platformTypeLogo;
}
//通过名称获取平台
- (UMSocialPlatformType)getPlatformTypeByPlatformTypeName:(NSString *)platformTypeName
{
    if ([platformTypeName isEqualToString:@"微信"]) {
        return UMSocialPlatformType_WechatSession;
    }else if ([platformTypeName isEqualToString:@"朋友圈"])
    {
        return UMSocialPlatformType_WechatTimeLine;
    }else if ([platformTypeName isEqualToString:@"QQ"])
    {
        return UMSocialPlatformType_QQ;
    }
    return UMSocialPlatformType_UnKnown;
}
#pragma mark - 初始化
- (NSMutableArray *)platformTypeNames
{
    if (_platformTypeNames == nil) {
        _platformTypeNames = [NSMutableArray array];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {//如果安装微信
            [_platformTypeNames addObject:@"微信"];
            [_platformTypeNames addObject:@"朋友圈"];
        }
    }
    return _platformTypeNames;
}

@end
