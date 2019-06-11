//
//  DRRedPacketView.m
//  dr
//
//  Created by 毛文豪 on 2018/2/2.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRRedPacketView.h"
#import "DRRedPacketViewController.h"
#import "DRShareTool.h"

@interface DRRedPacketView ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UINavigationController *currentViewController;
@property (nonatomic,assign) BOOL isRegisterRedPacket;
@property (nonatomic,weak) UIImageView * imageView;
@property (nonatomic,weak) UIButton *confirmButton;

@end

@implementation DRRedPacketView

- (instancetype)initWithFrame:(CGRect)frame viewController:(UINavigationController *)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentViewController = viewController;
        self.isRegisterRedPacket = YES;
        [self setupChildViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scaleScreenWidth(343), screenWidth / 375 * 410)];
    self.imageView = imageView;
    imageView.center = self.center;
    if (self.isRegisterRedPacket) {
        imageView.image = [UIImage imageNamed:@"register_red_packet"];
    }else
    {
        imageView.image = [UIImage imageNamed:@"order_red_packet"];
    }
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //按钮
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton = confirmButton;
    confirmButton.frame = CGRectMake(imageView.width * 0.2, imageView.height * 0.69, imageView.width * 0.6, imageView.height * 0.15);
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:confirmButton];

    //动画
    imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:DRAnimateDuration
                     animations:^{
                         imageView.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

- (void)confirmButtonDidClick
{
    [self removeFromSuperview];
    if (self.isRegisterRedPacket) {
        [self.currentViewController pushViewController:[DRRedPacketViewController new] animated:YES];
    }else
    {
        [self getShareUrlByRewardId:self.rewardId];
    }
}

- (void)getShareUrlByRewardId:(NSString *)rewardId
{
    NSDictionary *bodyDic = @{
                              @"rewardId":rewardId
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"C09",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"请稍后" toView:self];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self];
        if (SUCCESS) {
            //180306115211010006
            [DRShareTool shareRedPacketWithRewardUrl:json[@"rewardUrl"] amountMoney:self.price];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self];
    }];
}

- (void)hide
{
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint imageViewPos = [touch locationInView:self.imageView.superview];
        if (CGRectContainsPoint(self.imageView.frame, imageViewPos)) {
            CGPoint buttonPos = [touch locationInView:self.confirmButton.superview];
            if (!CGRectContainsPoint(self.confirmButton.frame, buttonPos)) {
                return NO;
            }
        }
    }
    return YES;
}

@end
