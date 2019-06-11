//
//  DRMailTemplateTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRMailTemplateTableViewCell.h"
#import "DRDecimalTextField.h"

@interface DRMailTemplateTableViewCell ()

@property (nonatomic,weak) UILabel * nameLabel;
@property (nonatomic,weak) UILabel * contentLabel;
@property (nonatomic,weak) UIButton * deleteButton;
@property (nonatomic,weak) UIButton * editButton;

@end

@implementation DRMailTemplateTableViewCell

+ (DRMailTemplateTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"MailTemplateTableViewCellId";
    DRMailTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRMailTemplateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 9)];
    lineView.backgroundColor = DRBackgroundColor;
    [self addSubview:lineView];
    
    //运费名称
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9, screenWidth - 2 * DRMargin, 40)];
    self.nameLabel = nameLabel;
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [self addSubview:nameLabel];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 9 + 40, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //运费详情
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 9 + 40, screenWidth, 60)];
    self.contentLabel = contentLabel;
    contentLabel.textColor = DRBlackTextColor;
    contentLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    contentLabel.numberOfLines = 0;
    [self addSubview:contentLabel];
    
    nameLabel.text = @"运费1";
    NSMutableAttributedString * contentAttStr = [[NSMutableAttributedString alloc] initWithString:@"2件以下，运费5元\n增加1件，运费加5元"];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [contentAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentAttStr.length)];
    contentLabel.attributedText = contentAttStr;
    
    //底部视图
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(contentLabel.frame), screenWidth, 35)];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomView];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [bottomView addSubview:line2];
    
    //删除
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton = deleteButton;
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    CGSize deleteButtonSize = [deleteButton.currentTitle sizeWithLabelFont:deleteButton.titleLabel.font];
    deleteButton.frame = CGRectMake(screenWidth - DRMargin - deleteButtonSize.width, 0, deleteButtonSize.width, 35);
    [bottomView addSubview:deleteButton];
    
    //编辑
    UIButton * editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editButton = editButton;
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [editButton addTarget:self action:@selector(editButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    CGSize editButtonSize = [editButton.currentTitle sizeWithLabelFont:editButton.titleLabel.font];
    editButton.frame = CGRectMake(deleteButton.frame.origin.x - DRMargin - editButtonSize.width, 0, editButtonSize.width, 35);
    [bottomView addSubview:editButton];
}


- (void)editButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(MailTemplateTableViewCellEditButtonDidClickWithCell:)]) {
        [_delegate mailTemplateTableViewCellEditButtonDidClickWithCell:self];
    }
}

- (void)deleteButtonDidClick
{
    if (_delegate && [_delegate respondsToSelector:@selector(MailTemplateTableViewCellDeleteButtonDidClickWithCell:)]) {
        [_delegate mailTemplateTableViewCellDeleteButtonDidClickWithCell:self];
    }
}

@end
