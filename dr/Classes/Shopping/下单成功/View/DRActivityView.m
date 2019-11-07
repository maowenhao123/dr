//
//  DRActivityView.m
//  dr
//
//  Created by 毛文豪 on 2018/11/27.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRActivityView.h"
#import "DRLoadHtmlFileViewController.h"
#import "DRShareTool.h"
#import "DRShareView.h"

@interface DRActivityView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UIButton *button;

@end

@implementation DRActivityView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, self.width - 10, 20)];
    self.titleLabel = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    //内容
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLabel.frame), self.width - 10, 32)];
    self.contentLabel = contentLabel;
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 2;
    [self addSubview:contentLabel];
    
    //按钮
    CGFloat buttonW = 80;
    CGFloat buttonH = 25;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button = button;
    button.frame = CGRectMake((self.width - buttonW) / 2, CGRectGetMaxY(contentLabel.frame) + 2, buttonW, buttonH);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = buttonH / 2;
    [button addTarget:self action:@selector(buttonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)setActivityModel:(DRActivityModel *)activityModel
{
    _activityModel = activityModel;
    
    if ([self.activityModel.type intValue] == 1) {//分享
        self.image = [UIImage imageNamed:@"order_redPacket"];
    }else if ([self.activityModel.type intValue] == 2)//H5
    {
        self.image = [UIImage imageNamed:@"order_water"];
    }else
    {
        NSString *colorStr = _activityModel.background;
        colorStr = [colorStr stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
        unsigned long colorInt = strtoul([colorStr UTF8String], 0, 0);//转换成16进制
        self.backgroundColor = UIColorFromRGB(colorInt);
    }
    
    if ([self.activityModel.type intValue] == 1) {//分享
        [self.button setTitle:@"开" forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(35)];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor clearColor];
        self.titleLabel.frame = CGRectMake(5, 5, self.width - 10, 20);
        if (iPhone4 || iPhone5 || iPhone6) {
            self.button.frame = CGRectMake(5, CGRectGetMaxY(self.titleLabel.frame), self.width - 10, 40);
        }else
        {
            self.button.frame = CGRectMake(5, CGRectGetMaxY(self.titleLabel.frame), self.width - 10, 42);
            self.button.centerY = self.height / 2;
        }
        self.contentLabel.frame = CGRectMake(5, self.height - 20 - 3, self.width - 10, 20);
    }else
    {
        [self.button setTitle:_activityModel.button forState:UIControlStateNormal];
        [self.button setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor whiteColor];
        self.button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        self.titleLabel.frame = CGRectMake(5, 5, self.width - 10, 20);
        self.contentLabel.frame = CGRectMake(5, CGRectGetMaxY(self.titleLabel.frame), self.width - 10, 32);
        CGFloat buttonW = 80;
        CGFloat buttonH = 25;
        self.button.frame = CGRectMake((self.width - buttonW) / 2, self.height - buttonH - 3, buttonW, buttonH);
    }
    self.titleLabel.text = _activityModel.title;
    self.contentLabel.text = _activityModel.content;
}

- (void)buttonDidClick
{
    if ([self.activityModel.type intValue] == 1) {//分享
        DRShareView * shareView = [[DRShareView alloc] init];
        [shareView show];
        shareView.block = ^(UMSocialPlatformType platformType){//选择平台
            [DRShareTool shareWithTitle:self.activityModel.title description:self.activityModel.content imageUrl:nil image:[UIImage imageNamed:@"order_red_packet_share_icon"] platformType:platformType url:self.activityModel.url];
        };
    }else if ([self.activityModel.type intValue] == 2)//H5
    {
        DRLoadHtmlFileViewController * htmlVC = [[DRLoadHtmlFileViewController alloc] initWithWeb:self.activityModel.url];
        [self.viewController.navigationController pushViewController:htmlVC animated:YES];
    }
}

@end
