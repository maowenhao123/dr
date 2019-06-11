//
//  DRVideoPlayerViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/12/4.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRVideoPlayerViewController.h"
#import "CLPlayerView.h"

@interface DRVideoPlayerViewController ()

@property (nonatomic, weak) CLPlayerView *playerView;

@end

@implementation DRVideoPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"播放";
    [self initView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_playerView destroyPlayer];
    _playerView = nil;
}

- (void)initView
{
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.playerView = playerView;
    [playerView updateWithConfig:^(CLPlayerViewConfig *config) {
        config.backPlay = NO;
        config.repeatPlay = YES;
        config.videoFillMode = VideoFillModeResizeAspect;
        config.topToolBarHiddenType = HiddenSmall;
        config.fullStatusBarHiddenType = FullStatusBarHiddenAlways;
        config.strokeColor = DRDefaultColor;
    }];
    if (!DRStringIsEmpty(self.urlString)) {
        playerView.url = [NSURL URLWithString:self.urlString];
    }else
    {
        playerView.url = self.url;
    }
    [_playerView resetPlay];
    [self.view addSubview:playerView];
}

@end
