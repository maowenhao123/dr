//
//  DRSystemMessageView.m
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSystemMessageView.h"

@interface DRSystemMessageView ()

@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel *badgeView;
@property (nonatomic, weak) UILabel * titleLabel;

@end

@implementation DRSystemMessageView

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
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap)];
    [self addGestureRecognizer:tap];
    
    //分割线
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, DRMargin, 40, 40)];
    self.avatarImageView = avatarImageView;
    [self addSubview:avatarImageView];
    
    //角标
    CGFloat badgeViewWH = 20;
    UILabel *badgeView = [[UILabel alloc] initWithFrame:CGRectMake(avatarImageView.width + 3 - badgeViewWH, -3, badgeViewWH, badgeViewWH)];
    self.badgeView = badgeView; 
    badgeView.textAlignment = NSTextAlignmentCenter;
    badgeView.textColor = [UIColor whiteColor];
    badgeView.backgroundColor = [UIColor redColor];
    badgeView.font = [UIFont boldSystemFontOfSize:11];
    badgeView.layer.cornerRadius = badgeViewWH / 2;
    badgeView.clipsToBounds = YES;
    badgeView.hidden = YES;
    [avatarImageView addSubview:badgeView];
    
    //昵称
    UILabel * titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:titleLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:timeLabel];
    
    //消息内容
    UILabel * contentLabel = [[UILabel alloc] init];
    self.contentLabel = contentLabel;
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
}

- (void)viewDidTap
{
    if (_delegate && [_delegate respondsToSelector:@selector(systemMessageViewDidClick:)]) {
        [_delegate systemMessageViewDidClick:self];
    }
}

- (void)setMessageModel:(DRMessageModel *)messageModel
{
    _messageModel = messageModel;
    
    self.avatarImageView.image = [UIImage imageNamed:_messageModel.imageName];
    self.titleLabel.text = _messageModel.title;
    self.timeLabel.text = _messageModel.time;
    self.contentLabel.text = _messageModel.detail;
    
    CGSize titleLabelSize = [self.titleLabel.text sizeWithLabelFont:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(DRMargin + 40 + DRMargin, DRMargin, titleLabelSize.width, titleLabelSize.height);
    
    CGSize timeLabelSize = [self.timeLabel.text sizeWithLabelFont:self.timeLabel.font];
    self.timeLabel.frame = CGRectMake(screenWidth - DRMargin - timeLabelSize.width, DRMargin, timeLabelSize.width, timeLabelSize.height);
    
    CGFloat contentLabelX = DRMargin + 40 + DRMargin;
    self.contentLabel.frame = CGRectMake(contentLabelX, CGRectGetMaxY(self.titleLabel.frame), screenWidth - contentLabelX - DRMargin, CGRectGetMaxY(self.avatarImageView.frame) - CGRectGetMaxY(self.titleLabel.frame));
}

- (void)setBadge:(NSInteger)badge
{
    _badge = badge;
    self.badgeView.hidden = badge == 0;
    self.badgeView.text = [NSString stringWithFormat:@"%ld", (long)_badge];
}

@end
