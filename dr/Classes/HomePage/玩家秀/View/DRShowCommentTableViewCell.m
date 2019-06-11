//
//  DRShowCommentTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/3/31.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowCommentTableViewCell.h"
#import "DRUserShowViewController.h"

@interface DRShowCommentTableViewCell ()

@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UILabel * nickNameLabel;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * commentLabel;
@property (nonatomic, weak) UIButton * commentButton;

@end

@implementation DRShowCommentTableViewCell

+ (DRShowCommentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShowCommentTableViewCellId";
    DRShowCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShowCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    //分割线
    UIView * line = [[UIView alloc]init];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 10, 36, 36)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarDidClick)];
    avatarImageView.userInteractionEnabled = YES;
    [avatarImageView addGestureRecognizer:tap];
    
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
    
    //评论内容
    UILabel * commentLabel = [[UILabel alloc] init];
    self.commentLabel = commentLabel;
    commentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    commentLabel.textColor = DRGrayTextColor;
    commentLabel.numberOfLines = 0;
    [self addSubview:commentLabel];
    
    //评论按钮
    UIButton * commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton = commentButton;
    [commentButton setImage:[UIImage imageNamed:@"show_comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentButton];
}

- (void)avatarDidClick
{
    [self.viewController.view endEditing:YES];
    
    DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
    showDetailVC.userId = self.model.userId;
    showDetailVC.nickName = self.model.userNickName;
    showDetailVC.userHeadImg = self.model.userHeadImg;
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}

- (void)commentButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(showCommentTableViewCellcommentButtonDidClickWithCell:)]) {
        [_delegate showCommentTableViewCellcommentButtonDidClickWithCell:self];
    }
}

- (void)setModel:(DRShowCommentModel *)model
{
    _model = model;
    
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_model.userHeadImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    self.nickNameLabel.text = _model.userNickName;

    self.timeLabel.text = _model.timeStr;
    
    if (_model.toUser) {
        self.commentLabel.text = [NSString stringWithFormat:@"回复%@：%@", _model.toUser.nickName, _model.content];
    }else
    {
        self.commentLabel.text = _model.content;
    }
    
    //frame
    self.nickNameLabel.frame = _model.nickNameLabelF;
    if (_model.isFirst) {
        self.line.frame = CGRectMake(0, 0, screenWidth, 1);
    }else
    {
        self.line.frame = CGRectMake(self.nickNameLabel.x, 0, screenWidth - self.nickNameLabel.x, 1);
    }
    self.timeLabel.frame = _model.timeLabelF;
    self.commentLabel.frame = _model.commentLabelF;
    self.commentButton.frame = _model.commentButtonF;
}


@end
