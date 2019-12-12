//
//  DRGoodCommentView.m
//  dr
//
//  Created by dahe on 2019/11/20.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodCommentView.h"

@interface DRGoodCommentView ()

@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel * nickNameLabel;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * commentLabel;
@property (nonatomic, weak) UILabel * levelLabel;

@end

@implementation DRGoodCommentView

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
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];

    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 10, 36, 36)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    nickNameLabel.textColor = DRBlackTextColor;
    [self addSubview:nickNameLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    timeLabel.textColor = DRGrayTextColor;
    [self addSubview:timeLabel];
    
    //评论
    UILabel * commentLabel = [[UILabel alloc] init];
    self.commentLabel = commentLabel;
    commentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    commentLabel.textColor = DRBlackTextColor;
    commentLabel.numberOfLines = 0;
    [self addSubview:commentLabel];
    
    //等级
    UILabel * levelLabel = [[UILabel alloc] init];
    self.levelLabel = levelLabel;
    levelLabel.backgroundColor = DRColor(255, 242, 204, 1);
    levelLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    levelLabel.textColor = DRViceColor;
    levelLabel.textAlignment = NSTextAlignmentCenter;
    levelLabel.layer.masksToBounds = YES;
    levelLabel.layer.cornerRadius = 3;
    [self addSubview:levelLabel];
}

- (void)setModel:(DRGoodCommentModel *)model
{
    _model = model;
    
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _model.userHeadImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    self.nickNameLabel.text = _model.userNickName;
    self.timeLabel.text = _model.timeStr;
    self.commentLabel.text = _model.content;
    self.levelLabel.text = _model.levelDesc;
    
    //frame
    self.nickNameLabel.frame = _model.nickNameLabelF;
    self.timeLabel.frame = _model.timeLabelF;
    if (DRStringIsEmpty(_model.levelDesc)) {
        self.levelLabel.hidden = YES;
    }else
    {
        self.levelLabel.hidden = NO;
        self.levelLabel.frame = _model.levelLabelF;
    }
    self.commentLabel.frame = _model.commentLabelF;
}


@end
