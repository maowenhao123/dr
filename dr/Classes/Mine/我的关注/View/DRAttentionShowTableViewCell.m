//
//  DRAttentionShowTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/7/18.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAttentionShowTableViewCell.h"

@interface DRAttentionShowTableViewCell ()

@property (nonatomic,weak) UILabel * nickNameLabel;
@property (nonatomic,weak) UIImageView * avatarImageView;

@end

@implementation DRAttentionShowTableViewCell

+ (DRAttentionShowTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"AttentionShowTableViewCellId";
    DRAttentionShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRAttentionShowTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //头像
    UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(lineView.frame) + 7.5, 35, 35)];
    self.avatarImageView = avatarImageView;
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [self addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc] init];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.textColor = DRGrayTextColor;
    nickNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [self addSubview:nickNameLabel];

    //取消关注
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(screenWidth - DRMargin - 70, CGRectGetMaxY(lineView.frame) + (50 - 27) / 2, 70, 27);
    [cancelButton setTitle:@"取消关注" forState:UIControlStateNormal];
    [cancelButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.cornerRadius = cancelButton.height / 2;
    cancelButton.layer.borderColor = DRGrayLineColor.CGColor;
    cancelButton.layer.borderWidth = 1;
    [cancelButton addTarget:self action:@selector(cancelButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
}

- (void)cancelButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(attentionShowTableViewCell:cancelAttentionButtonDidClick:)]) {
        [_delegate attentionShowTableViewCell:self cancelAttentionButtonDidClick:button];
    }
}

- (void)setJson:(id)json
{
    _json = json;
    
    //赋值
    NSString * avatarUrlStr = [NSString stringWithFormat:@"%@%@",baseUrl, _json[@"user"][@"headImg"]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
    
    if (DRStringIsEmpty(_json[@"user"][@"nickName"])) {
        self.nickNameLabel.text = _json[@"user"][@"loginName"];
    }else
    {
        self.nickNameLabel.text = _json[@"user"][@"nickName"];
    }
    
    //frame
    CGSize nickNameLabelSize = [self.nickNameLabel.text sizeWithLabelFont:self.nickNameLabel.font];
    self.nickNameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 5, 0, nickNameLabelSize.width, 50);
}

@end
