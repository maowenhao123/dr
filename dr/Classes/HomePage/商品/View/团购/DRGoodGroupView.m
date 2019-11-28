//
//  DRGoodGroupView.m
//  dr
//
//  Created by dahe on 2019/11/20.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodGroupView.h"

@interface DRGoodGroupView ()

@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel * nickNameLabel;
@property (nonatomic, weak) UILabel * plusLabel;
@property (nonatomic, weak) UILabel * timeLabel;

@end

@implementation DRGoodGroupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //头像
    CGFloat avatarImageViewWH = 40;
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, (70 - avatarImageViewWH) / 2, avatarImageViewWH, avatarImageViewWH)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //昵称
    CGFloat nickNameLabelX = CGRectGetMaxX(avatarImageView.frame) + 5;
    CGFloat nickNameLabelW = screenWidth - nickNameLabelX - DRMargin - 70 - DRMargin - 100;
    UILabel * nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nickNameLabelX, 0, nickNameLabelW, 70)];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    nickNameLabel.textColor = DRBlackTextColor;
    [self addSubview:nickNameLabel];
    
    //剩余
    CGFloat plusLabelW = 100;
    CGFloat plusLabelX = screenWidth - DRMargin - 70 - DRMargin - 100;
    UILabel * plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(plusLabelX, 12, plusLabelW, 23)];
    self.plusLabel = plusLabel;
    plusLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    plusLabel.textColor = DRBlackTextColor;
    plusLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:plusLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(plusLabelX, 35, plusLabelW, 23)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    timeLabel.textColor = DRGrayTextColor;
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:timeLabel];
    
    //去参团
    UIButton * groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat groupButtonW = 70;
    CGFloat groupButtonH = 30;
    groupButton.frame = CGRectMake(screenWidth - DRMargin - groupButtonW, (70 - groupButtonH) / 2, groupButtonW, groupButtonH);
    [groupButton setTitle:@"去参团" forState:UIControlStateNormal];
    groupButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    groupButton.layer.masksToBounds = YES;
    groupButton.layer.cornerRadius = 3;
    groupButton.layer.borderWidth = 1;
    groupButton.layer.borderColor = DRDefaultColor.CGColor;
    [groupButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    [groupButton addTarget:self action:@selector(groupButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:groupButton];
    
    
    avatarImageView.image = [UIImage imageNamed:@"avatar_placeholder"];
    nickNameLabel.text = @"昵称";
    plusLabel.text = @"还差1件";
    timeLabel.text = @"剩余47:42:01";
}

- (void)groupButtonDidClick
{
    
}

@end
