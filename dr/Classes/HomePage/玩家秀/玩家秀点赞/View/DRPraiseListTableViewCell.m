//
//  DRPraiseListTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/12/17.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseListTableViewCell.h"

@interface DRPraiseListTableViewCell ()

@property (nonatomic, weak) UILabel *rankLabel;
@property (nonatomic, weak) UIImageView *rankImageView;
@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel * nickNameLabel;
@property (nonatomic, weak) UILabel *praiseNumberLabel;
@property (nonatomic,weak) UIButton * attentionButton;

@end

@implementation DRPraiseListTableViewCell

+ (DRPraiseListTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"PraiseListTableViewCellId";
    DRPraiseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRPraiseListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return  cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    CGFloat cellH = 80;
    //排名
    CGFloat rankViewW = 30;
    CGFloat rankViewH = 30;
    UILabel * rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (cellH - rankViewH) / 2, rankViewW, rankViewH)];
    self.rankLabel = rankLabel;
    rankLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(36)];
    rankLabel.textColor = DRColor(122, 22, 36, 1);
    rankLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:rankLabel];
    
    UIImageView * rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, (cellH - rankViewH) / 2, rankViewW, rankViewH)];
    self.rankImageView = rankImageView;
    [self addSubview:rankImageView];
    
    //头像
    CGFloat avatarImageViewWH = 60;
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rankLabel.frame) + 7, DRMargin, avatarImageViewWH, avatarImageViewWH)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.userInteractionEnabled = YES;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.textColor = DRBlackTextColor;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:nickNameLabel];
    
    //点赞数
    UILabel * praiseNumberLabel = [[UILabel alloc] init];
    self.praiseNumberLabel = praiseNumberLabel;
    praiseNumberLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    praiseNumberLabel.textColor = DRPraiseRedTextColor;
    [self addSubview:praiseNumberLabel];
    
    //关注
    CGFloat attentionButtonW = 70;
    CGFloat attentionButtonH = 27;
    UIButton * attentionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.attentionButton = attentionButton;
    attentionButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [attentionButton setTitle:@"+关注" forState:UIControlStateNormal];
    [attentionButton setTitleColor:DRPraiseRedTextColor forState:UIControlStateNormal];
    attentionButton.frame = CGRectMake(screenWidth - (attentionButtonW + 15), (80 - attentionButtonH) / 2, attentionButtonW, attentionButtonH);
    [attentionButton addTarget:self action:@selector(attentionButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    attentionButton.layer.masksToBounds = YES;
    attentionButton.layer.cornerRadius = attentionButton.height / 2;
    attentionButton.layer.borderWidth = 1;
    attentionButton.layer.borderColor = DRPraiseRedTextColor.CGColor;
    [self addSubview:attentionButton];
    
    nickNameLabel.frame = CGRectMake(CGRectGetMaxX(avatarImageView.frame) + DRMargin, 15, attentionButton.x - CGRectGetMaxX(avatarImageView.frame) - 2 * DRMargin, 25);
    praiseNumberLabel.frame = CGRectMake(CGRectGetMaxX(avatarImageView.frame) + DRMargin, 40, attentionButton.x - CGRectGetMaxX(avatarImageView.frame) - 2 * DRMargin, 25);
}

- (void)attentionButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(praiseListTableViewCellPraiseButtonDidClickWithCell:)]) {
        [_delegate praiseListTableViewCellPraiseButtonDidClickWithCell:self];
    }
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    self.rankLabel.hidden = YES;
    self.rankLabel.text = nil;
    self.rankImageView.hidden = YES;
    self.rankImageView.image = nil;
    if (_index == 0) {
        self.rankImageView.hidden = NO;
        self.rankImageView.image = [UIImage imageNamed:@"show_praise_rank_1"];
    }else if (_index == 1) {
        self.rankImageView.hidden = NO;
        self.rankImageView.image = [UIImage imageNamed:@"show_praise_rank_2"];
    }else if (_index == 2) {
        self.rankImageView.hidden = NO;
        self.rankImageView.image = [UIImage imageNamed:@"show_praise_rank_3"];
    }else
    {
        self.rankLabel.hidden = NO;
        self.rankLabel.text = [NSString stringWithFormat:@"%ld", _index + 1];
    }
}

- (void)setPraiseModel:(DRPraiseModel *)praiseModel
{
    _praiseModel = praiseModel;
    
    NSString * imageUrlStr = _praiseModel.userHeadImg;
    if (![imageUrlStr containsString:@"http"]) {
        imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _praiseModel.userHeadImg];
    }
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    self.nickNameLabel.text = praiseModel.userNickName;
    
    self.praiseNumberLabel.text = [NSString stringWithFormat:@"点赞数：%@", _praiseModel.praiseCount];
    
    if ([_praiseModel.focus boolValue]) {
        [self.attentionButton setTitle:@"已关注" forState:UIControlStateNormal];
    }else
    {
        [self.attentionButton setTitle:@"+关注" forState:UIControlStateNormal];
    }
}

@end
