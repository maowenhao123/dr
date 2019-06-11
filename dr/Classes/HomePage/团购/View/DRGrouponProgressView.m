//
//  DRGrouponProgressView.m
//  dr
//
//  Created by 毛文豪 on 2017/4/27.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGrouponProgressView.h"

@interface DRGrouponProgressView ()

@property (nonatomic, weak) UIView * progressView;
@property (nonatomic, weak) UILabel * progressLabel;

@end

@implementation DRGrouponProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    self.backgroundColor = DRColor(20, 215, 167, 1);
    
    //边框
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.height / 2;
    self.layer.borderColor = DRDefaultColor.CGColor;
    self.layer.borderWidth = 1;
    
    //已买
    UIView * progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
    self.progressView = progressView;
    progressView.backgroundColor = DRDefaultColor;
    progressView.layer.cornerRadius = progressView.height / 2;
    progressView.layer.borderColor = DRDefaultColor.CGColor;
    [self addSubview:progressView];
    
    //已买label
    UILabel * progressLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.progressLabel = progressLabel;
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.font = [UIFont systemFontOfSize:DRGetFontSize(18)];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:progressLabel];
}

- (void)setProgress:(double)progress
{
    _progress = progress;
    
    _progress = round(_progress * 100) / 100;
    _progress = _progress < 0 ? 0 : _progress;
    _progress = _progress > 100 ? 100 : _progress;
    self.progressView.width = self.width * _progress / 100;
    
    if (fmodf(_progress, 1) == 0) {//如果没有小数点
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_progress];
    }else if (fmodf(_progress * 10, 1) == 0)//如果有一位小数点
    {
        self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%",_progress];
    }else
    {
        NSLog(@"%f", _progress);
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",_progress];
    }
    
}

@end
