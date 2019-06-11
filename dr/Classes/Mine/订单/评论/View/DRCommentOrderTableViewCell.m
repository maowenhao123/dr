//
//  DRCommentOrderTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/6/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRCommentOrderTableViewCell.h"

@interface DRCommentOrderTableViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic,weak) UIButton *commentButton;

@end

@implementation DRCommentOrderTableViewCell

+ (DRCommentOrderTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"CommentOrderTableViewCellId";
    DRCommentOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRCommentOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 12, 76, 76)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [self addSubview:goodNameLabel];
    
    // 去评价
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton = commentButton;
    CGFloat commentButtonW = 70;
    CGFloat commentButtonH = 26;
    self.commentButton.frame = CGRectMake(screenWidth - DRMargin - commentButtonW, CGRectGetMaxY(self.goodImageView.frame) - commentButtonH, commentButtonW, commentButtonH);
    commentButton.backgroundColor = DRDefaultColor;
    [commentButton setTitle:@"去评价" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commentButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [commentButton addTarget:self action:@selector(commentButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    commentButton.layer.masksToBounds = YES;
    commentButton.layer.cornerRadius = 4;
    [self addSubview:commentButton];
}
- (void)commentButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentOrderTableViewCell:commentButtonDidClick:)]) {
        [_delegate commentOrderTableViewCell:self commentButtonDidClick:button];
    }
}
- (void)setCommentGoodModel:(DRCommentGoodModel *)commentGoodModel
{
    _commentGoodModel = commentGoodModel;
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@%@",baseUrl,_commentGoodModel.goods.spreadPics,smallPicUrl];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    if (DRStringIsEmpty(_commentGoodModel.goods.description_)) {
        self.goodNameLabel.text = _commentGoodModel.goods.name;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithLabelFont:self.goodNameLabel.font];
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", _commentGoodModel.goods.name, _commentGoodModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _commentGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( _commentGoodModel.goods.name.length, nameAttStr.length - _commentGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.string.length)];
        self.goodNameLabel.attributedText = nameAttStr;
        
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - CGRectGetMaxX(self.goodImageView.frame) - 2 * DRMargin, 40) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + DRMargin;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, self.goodImageView.y + 3, goodNameLabelSize.width, goodNameLabelSize.height);
    }
    
    if ([_commentGoodModel.commentStatus boolValue] == YES) {
        self.commentButton.backgroundColor = [UIColor lightGrayColor];
        [self.commentButton setTitle:@"已评价" forState:UIControlStateNormal];
        self.commentButton.enabled = NO;
    }else
    {
        self.commentButton.backgroundColor = DRDefaultColor;
        [self.commentButton setTitle:@"去评价" forState:UIControlStateNormal];
        self.commentButton.enabled = YES;
    }
}

@end
