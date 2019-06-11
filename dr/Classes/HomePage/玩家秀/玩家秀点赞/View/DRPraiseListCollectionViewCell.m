//
//  DRPraiseListCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/12/18.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseListCollectionViewCell.h"
#import "UIButton+DR.h"

@interface DRPraiseListCollectionViewCell ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nickNameLabel;
@property (nonatomic, weak) UIButton *praiseNumberButton;
@end

@implementation DRPraiseListCollectionViewCell

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
    //头像
    CGFloat avatarImageViewWH = 50;
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - avatarImageViewWH) / 2, 10, avatarImageViewWH, avatarImageViewWH)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(avatarImageView.frame) + 5, self.width, 20)];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    nickNameLabel.textColor = DRBlackTextColor;
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.text = @"昵称";
    [self addSubview:nickNameLabel];
    
    //点赞数
    UIButton * praiseNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseNumberButton = praiseNumberButton;
    praiseNumberButton.frame = CGRectMake(0, CGRectGetMaxY(nickNameLabel.frame), self.width, 20);
    [praiseNumberButton setImage:[UIImage imageNamed:@"show_praise_light"] forState:UIControlStateNormal];
    praiseNumberButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [praiseNumberButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    [self addSubview:praiseNumberButton];
}

- (void)setPraiseModel:(DRPraiseModel *)praiseModel
{
    _praiseModel = praiseModel;
    
    NSString * imageUrlStr = _praiseModel.userHeadImg;
    if (![imageUrlStr containsString:@"http"]) {
        imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _praiseModel.userHeadImg];
    }
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.nickNameLabel.text = _praiseModel.userNickName;
    
    [self.praiseNumberButton setTitle:[NSString stringWithFormat:@"点赞数:%@", _praiseModel.praiseCount] forState:UIControlStateNormal];
}


@end
