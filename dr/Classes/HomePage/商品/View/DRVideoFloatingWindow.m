//
//  DRVideoFloatingWindow.m
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRVideoFloatingWindow.h"
#import "DRVideoPlayerViewController.h"

@interface DRVideoFloatingWindow ()

@property (nonatomic, weak) UIView * viodeMaskView;
@property (nonatomic, weak) UIImageView *closeImageView;
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGFloat previousScale;
@property (nonatomic, assign) BOOL dragEnable;

@end

@implementation DRVideoFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChilds];
    }
    return self;
}

- (void)setupChilds
{
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:self.bounds];
    [playerView updateWithConfig:^(CLPlayerViewConfig *config) {
        config.backPlay = NO;
        config.strokeColor = DRDefaultColor;
        config.videoFillMode = VideoFillModeResizeAspect;
        config.topToolBarHiddenType = HiddenSmall;
    }];
    [self addSubview:playerView];
    [playerView backButton:^(UIButton *button) {
        self.hidden = YES;
        for (UIView * subView in self.barView.subviews) {
            subView.hidden = NO;
        }
    }];
    [playerView endPlay:^{
        self.hidden = YES;
        for (UIView * subView in self.barView.subviews) {
            subView.hidden = NO;
        }
    }];
    [playerView fullChange:^{
        [self bringSubviewToFront:self.viodeMaskView];
        if (_floatingWindowType == SmallVideoFloatingWindow && !playerView.isFullScreen) {
            [playerView updateWithConfig:^(CLPlayerViewConfig *config) {
                config.hiddenToolBar = YES;
                config.topToolBarHiddenType = HiddenAlways;
                config.exitButtonHiddenType = HiddenAlways;
            }];
        }
    }];
    self.playerView = playerView;
    
    UIView * viodeMaskView = [[UIView alloc] initWithFrame:self.bounds];
    self.viodeMaskView = viodeMaskView;
    [self addSubview:viodeMaskView];
    
    //关闭图片
    CGFloat closeImageViewWH = 30;
    UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - closeImageViewWH, 0, closeImageViewWH, closeImageViewWH)];
    self.closeImageView = closeImageView;
    closeImageView.image = [UIImage imageNamed:@"give_voucher_close"];
    [viodeMaskView addSubview:closeImageView];
    
    UITapGestureRecognizer * closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeImageViewDidClick)];
    closeImageView.userInteractionEnabled = YES;
    [closeImageView addGestureRecognizer:closeTap];
    
    UITapGestureRecognizer * detailTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [viodeMaskView addGestureRecognizer:detailTap];
    
    //添加移动手势可以拖动
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)closeImageViewDidClick
{
    self.hidden = YES;
    for (UIView * subView in self.barView.subviews) {
        subView.hidden = NO;
    }
}

- (void)tapAction
{
    [self.playerView updateWithConfig:^(CLPlayerViewConfig *config) {
        config.hiddenToolBar = NO;
        config.topToolBarHiddenType = HiddenSmall;
        config.exitButtonHiddenType = HiddenFull;
        [self.playerView fullVideoPlayer];
    }];
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    self.playerView.url = [NSURL URLWithString:_urlString];
}

- (void)setFloatingWindowType:(FloatingWindowType)floatingWindowType
{
    _floatingWindowType = floatingWindowType;
    
    self.playerView.frame = self.bounds;
    self.viodeMaskView.frame = self.bounds;
    self.viodeMaskView.hidden = _floatingWindowType == BannerVideoFloatingWindow;
    self.closeImageView.frame = CGRectMake(self.width - self.closeImageView.width, 0, self.closeImageView.width, self.closeImageView.height);
    
    [self.playerView updateWithConfig:^(CLPlayerViewConfig *config) {
        if (_floatingWindowType == SmallVideoFloatingWindow) {
            config.hiddenToolBar = YES;
            config.topToolBarHiddenType = HiddenAlways;
            config.exitButtonHiddenType = HiddenAlways;
        }else
        {
            config.hiddenToolBar = NO;
            config.topToolBarHiddenType = HiddenSmall;
            config.exitButtonHiddenType = HiddenFull;
        }
    }];
}

//拖动事件
-(void)dragAction:(UIPanGestureRecognizer *)pan
{
    if (_floatingWindowType == BannerVideoFloatingWindow || self.playerView.isFullScreen)return;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{///开始拖动
            [pan setTranslation:CGPointZero inView:self];
            self.startPoint = [pan translationInView:self];
            [self.superview bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{///拖动中
            CGPoint point = [pan translationInView:self];
            float dx = point.x - self.startPoint.x;
            float dy = point.y - self.startPoint.y;
            float newX = self.centerX + dx;
            float newY = self.centerY + dy;
            if (newX < self.width / 2) {
                newX = self.width / 2;
            }
            if (newX > screenWidth - self.width / 2) {
                newX = screenWidth - self.width / 2;
            }
            if (newY < statusBarH + navBarH + self.height / 2) {
                newY = statusBarH + navBarH + self.height / 2;
            }
            if (newY > screenHeight - [DRTool getSafeAreaBottom] - self.height / 2) {
                newY = screenHeight - [DRTool getSafeAreaBottom] - self.height / 2;
            }
            self.center = CGPointMake(newX, newY);
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{///拖动结束
            [self keepBounds];
            break;
        }
        default:
            break;
    }
}

- (void)keepBounds
{
    CGFloat centerX;
    if (self.centerX < screenWidth / 2) {
        centerX = self.width / 2;
    }else
    {
        centerX = screenWidth - self.width / 2;
    }
    
    [UIView animateWithDuration:DRAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.centerX = centerX;
    } completion:nil];
}

@end
