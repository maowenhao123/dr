//
//  DRShowListCommentTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/7/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowListCommentTableViewCell.h"
#import "DRUserShowViewController.h"
#import "UILabel+DR.h"

@interface DRShowListCommentTableViewCell ()<UITextViewDelegate>

@property (nonatomic, weak) UILabel * commentLabel;

@end

@implementation DRShowListCommentTableViewCell

+ (DRShowListCommentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShowListCommentTableViewCellId";
    DRShowListCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShowListCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    self.contentView.backgroundColor = DRColor(243, 243, 244, 1);
    
    UILabel * commentLabel = [[UILabel alloc] init];
    self.commentLabel = commentLabel;
    commentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    commentLabel.textColor = DRBlackTextColor;
    commentLabel.numberOfLines = 0;
    commentLabel.isShowTagEffect = NO;
    [self addSubview:commentLabel];
}
- (void)setModel:(DRShowCommentModel *)model
{
    _model = model;
    
    NSMutableAttributedString *commentContentAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:_model.commentContentAttStr];    
    self.commentLabel.attributedText = commentContentAttStr;
    self.commentLabel.frame = _model.listCommentLabelF;
    NSArray * nickNames = [NSArray array];
    if (!DRStringIsEmpty(_model.userNickName)) {
        nickNames = @[_model.userNickName];
    }
    if (!DRStringIsEmpty(_model.toUser.nickName)) {
        nickNames = @[_model.userNickName, _model.toUser.nickName];
    }
    if (DRArrayIsEmpty(nickNames)) {
        return;
    }
    typeof(self) __weak weakSelf = self;
    [self.commentLabel onTapRangeActionWithString:nickNames tapClicked:^(NSString *string, NSRange range, NSInteger index) {
        [self.viewController.view endEditing:YES];
        
        if (index == 0) {
            DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
            showDetailVC.userId = weakSelf.model.userId;
            showDetailVC.nickName = weakSelf.model.userNickName;
            showDetailVC.userHeadImg = weakSelf.model.userHeadImg;
            [weakSelf.viewController.navigationController pushViewController:showDetailVC animated:YES];
        }else
        {
            DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
            showDetailVC.userId = weakSelf.model.toUser.id;
            showDetailVC.nickName = weakSelf.model.toUser.nickName;
            showDetailVC.userHeadImg = weakSelf.model.toUser.headImg;
            [weakSelf.viewController.navigationController pushViewController:showDetailVC animated:YES];
        }
    }];
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    DRLog(@"%@", URL);
    return YES;
}
@end
