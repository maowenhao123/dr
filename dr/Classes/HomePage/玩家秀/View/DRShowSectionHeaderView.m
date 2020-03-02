//
//  DRShowSectionHeaderView.m
//  dr
//
//  Created by 毛文豪 on 2018/12/13.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRShowSectionHeaderView.h"
#import "DRUserShowViewController.h"
#import "UIButton+DR.h"
#import "DRDateTool.h"
#import "DRShareTool.h"

@interface DRShowSectionHeaderView ()

@property (nonatomic, weak) UIImageView * avatarImageView;
@property (nonatomic, weak) UIButton * nickNameButton;
@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UIButton * shareButton;
@property (nonatomic, weak) UIButton * praiseButton;
@property (nonatomic, weak) UIButton * commentButton;
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * detailLabel;
@property (nonatomic,weak) UIImageView * triangleImageView;

@end

@implementation DRShowSectionHeaderView

+ (DRShowSectionHeaderView *)headerViewWithTableView:(UITableView *)talbeView
{
    static NSString *ID = @"ShowHeaderViewId";
    DRShowSectionHeaderView *headerView = [talbeView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DRShowSectionHeaderView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setupChildViews];
    }
    return self;
}
- (void)setupChildViews
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick)];
    [self addGestureRecognizer:tap];
    
    //分割线
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    lineView.backgroundColor = DRWhiteLineColor;
    [self addSubview:lineView];
    
    //头像
    CGFloat avatarImageViewWH = 36;
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 9, avatarImageViewWH, avatarImageViewWH)];
    self.avatarImageView = avatarImageView;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.userInteractionEnabled = YES;
    [self addSubview:avatarImageView];
    
    UITapGestureRecognizer * userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userShowDidClick)];
    [avatarImageView addGestureRecognizer:userTap];
    
    //分享
    CGFloat shareButtonWH = 45;
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton = shareButton;
    shareButton.frame = CGRectMake(screenWidth - 10 - shareButtonWH, avatarImageView.y, shareButtonWH, shareButtonWH);
    shareButton.centerY = self.avatarImageView.centerY;
    [shareButton setImage:[UIImage imageNamed:@"show_share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:shareButton];
    
    //昵称
    UIButton * nickNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nickNameButton = nickNameButton;
    nickNameButton.frame = CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, 9, screenWidth - (CGRectGetMaxX(avatarImageView.frame) + 5) - DRMargin, 20);
    [nickNameButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    nickNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    nickNameButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [nickNameButton addTarget:self action:@selector(userShowDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nickNameButton];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] init];
    self.timeLabel = timeLabel;
    timeLabel.frame = CGRectMake(nickNameButton.x, CGRectGetMaxY(nickNameButton.frame), screenWidth - nickNameButton.x - DRMargin, 16);
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
    timeLabel.textColor = DRGrayTextColor;
    [self addSubview:timeLabel];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame) + 53, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //标题
    UILabel * titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    titleLabel.textColor = DRBlackTextColor;
    [self addSubview:titleLabel];
    
    //描述
    UILabel * detailLabel = [[UILabel alloc] init];
    self.detailLabel = detailLabel;
    detailLabel.textColor = DRGrayTextColor;
    detailLabel.numberOfLines = 0;
    [self addSubview:detailLabel];
    
    //图片
    CGFloat padding = 5;
    CGFloat imageViewWH = (screenWidth - 4 * padding) / 3;
    UIImageView * lastImageView;
    for (int i = 0; i < 9; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        imageView.frame = CGRectMake(padding + (imageViewWH + padding) * (i % 3), 0, imageViewWH, imageViewWH);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.hidden = YES;
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
        lastImageView = imageView;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    
    //点赞
    UIButton * praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseButton = praiseButton;
    praiseButton.frame = CGRectMake(screenWidth - 2 * DRMargin - 2 * 26, CGRectGetMaxY(lastImageView.frame), 26, 26);
    [praiseButton setImage:[UIImage imageNamed:@"show_praise_gray"] forState:UIControlStateNormal];
    [praiseButton setImage:[UIImage imageNamed:@"show_praise_light"] forState:UIControlStateSelected];
    [praiseButton addTarget:self action:@selector(praiseButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:praiseButton];
    
    //评论
    UIButton * commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton = commentButton;
    commentButton.frame = CGRectMake(screenWidth -  DRMargin - 26, CGRectGetMaxY(lastImageView.frame), 26, 26);
    [commentButton setImage:[UIImage imageNamed:@"show_comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:commentButton];
    
    //三角
    UIImageView * triangleImageView = [[UIImageView alloc] init];
    self.triangleImageView = triangleImageView;
    triangleImageView.image = [UIImage imageNamed:@"show_triangle_up"];
    [self addSubview:triangleImageView];
}
- (void)tapDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(showHeaderViewShowDidClickWithHeaderView:)]) {
        [_delegate showHeaderViewShowDidClickWithHeaderView:self];
    }
}
- (void)userShowDidClick
{
    [self.viewController.view endEditing:YES];
    
    DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
    showDetailVC.userId = self.model.userId;
    showDetailVC.nickName = self.model.userNickName;
    showDetailVC.userHeadImg = self.model.userHeadImg;
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}
- (void)shareButtonDidClick:(UIButton *)button
{
    NSArray * imageUrls = [self.model.pics componentsSeparatedByString:@"|"];
    [DRShareTool shareShowWithShowId:self.model.id userNickName:self.model.userNickName title:self.model.name content:self.model.content imageUrl:[NSString stringWithFormat:@"%@%@%@", baseUrl, imageUrls.firstObject, smallPicUrl]];
}
- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    if (_delegate && [_delegate respondsToSelector:@selector(showHeaderViewShowImageDidClickWithHeaderView:imageView:)]) {
        [_delegate showHeaderViewShowImageDidClickWithHeaderView:self imageView:(UIImageView *)ges.view];
    }
}

- (void)praiseButtonDidClick:(UIButton *)button
{
    if (button.selected) {
        [MBProgressHUD showError:@"您已经点过赞啦"];
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(showHeaderViewPraiseDidClickWithHeaderView:)]) {
        [_delegate showHeaderViewPraiseDidClickWithHeaderView:self];
    }
}
- (void)commentButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(showHeaderViewCommentDidClickWithHeaderView:)]) {
        [_delegate showHeaderViewCommentDidClickWithHeaderView:self];
    }
}
- (void)setModel:(DRShowModel *)model
{
    _model = model;
    //赋值
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl,_model.userHeadImg];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    [self.nickNameButton setTitle:_model.userNickName forState:UIControlStateNormal];
    
    self.timeLabel.text = [DRDateTool getTimeByTimestamp:_model.createTime format:@"yyyy-MM-dd HH:mm:ss"];
    
    self.titleLabel.text = _model.name;
    self.detailLabel.attributedText = _model.detailAttStr;
    
    for (UIImageView * imageView in self.imageViews) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_model.pics,smallPicUrl];
        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    NSMutableArray *praiseUserIdArray = [NSMutableArray array];
    for (DRPraiseUserModel *praiseUserModel in _model.showPraiseModel.praiseList) {
        [praiseUserIdArray addObject:praiseUserModel.userId];
    }
    self.praiseButton.selected = [praiseUserIdArray containsObject:UserId];
    
    //frame
    self.titleLabel.frame = _model.titleLabelF;
    self.detailLabel.frame = _model.detailLabelF;
    
    //图片
    NSArray * imageUrls = [_model.pics componentsSeparatedByString:@"|"];
    NSInteger imageCount = imageUrls.count;//图片数量
    if (imageCount == 1) {
        NSString * imageUrl = imageUrls[0];
        if (DRStringIsEmpty(imageUrl)) {
            imageCount = 0;
        }
    }
    
    CGFloat padding = 5;
    CGFloat imageViewWH = (screenWidth - 4 * padding) / 3;
    UIImageView * lastImageView;
    for (int i = 0; i < self.imageViews.count; i++) {
        UIImageView * imageView = self.imageViews[i];
        imageView.hidden = YES;
        if (i < imageCount) {
            imageView.hidden = NO;
            imageView.y = CGRectGetMaxY(self.detailLabel.frame) + 12 + (imageViewWH + padding) * (i / 3) ;
            NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,imageUrls[i],smallPicUrl];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            lastImageView = imageView;
        }
    }
    
    self.praiseButton.y = CGRectGetMaxY(lastImageView.frame);
    self.commentButton.y = CGRectGetMaxY(lastImageView.frame);
    if ([_model.showPraiseModel.praiseCount intValue] > 0 || (_model.commentArray.count > 0 && _model.commentArray.count < 8)) {
        self.triangleImageView.hidden = NO;
    }else
    {
        self.triangleImageView.hidden = YES;
    }
    self.triangleImageView.frame = _model.triangleImageViewF;
}

#pragma mark - 初始化
- (NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

@end
