//
//  DRShowPraiseTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowPraiseTableViewCell.h"
#import "DRUserShowViewController.h"
#import "UIButton+DR.h"

@interface DRShowPraiseTableViewCell ()

@property (nonatomic, weak) UIView * line;
@property (nonatomic, strong) NSMutableArray * buttons;

@end

@implementation DRShowPraiseTableViewCell

+ (DRShowPraiseTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ShowPraiseTableViewCellId";
    DRShowPraiseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRShowPraiseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
    
    NSMutableArray * nickNames = [NSMutableArray array];
    for (int i = 0; i < 200; i++) {
        NSString * nickName = [NSString stringWithFormat:@"昵称%d", i];
        [nickNames addObject:nickName];
    }

    for (int i = 0; i < 200; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        if (i == 0) {
            [button setImage:[UIImage imageNamed:@"show_praise_gray"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"show_praise_light"] forState:UIControlStateSelected];
            [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        }else
        {
            [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        }
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        button.userInteractionEnabled = NO;
        [self addSubview:button];
        [self.buttons addObject:button];
    }
}
- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) return;
    NSArray <DRPraiseUserModel *>*praiseList = self.showPraiseModel.praiseList;
    if (button.tag - 1 > praiseList.count) return;
    [self.viewController.view endEditing:YES];
    
    DRPraiseUserModel * user = praiseList[button.tag - 1];
    DRUserShowViewController * showDetailVC = [[DRUserShowViewController alloc] init];
    showDetailVC.userId = user.userId;
    showDetailVC.nickName = user.userNickName;
    showDetailVC.userHeadImg = user.userHeadImg;
    [self.viewController.navigationController pushViewController:showDetailVC animated:YES];
}

- (void)setIsList:(BOOL)isList
{
    _isList = isList;
    if (_isList) {
        self.line.hidden = YES;
        self.contentView.backgroundColor = DRColor(243, 243, 244, 1);
    }else
    {
        self.line.hidden = NO;
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}
- (void)setShowPraiseModel:(DRShowPraiseModel *)showPraiseModel
{
    _showPraiseModel = showPraiseModel;
    NSMutableArray *praiseUserIdArray = [NSMutableArray array];
    for (DRPraiseUserModel *praiseUserModel in _showPraiseModel.praiseList) {
        [praiseUserIdArray addObject:praiseUserModel.userId];
    }
    for (UIButton * button in self.buttons) {
        button.hidden = YES;
        button.userInteractionEnabled = NO;
        if (_showPraiseModel.cellH != 0)
        {
            NSInteger index = [self.buttons indexOfObject:button];
            if (index < _showPraiseModel.praiseButtonFs.count) {
                button.hidden = NO;
                button.userInteractionEnabled = YES;
                CGRect rect = [_showPraiseModel.praiseButtonFs[index] CGRectValue];
                button.frame = rect;
                if (index != 0) {
                    DRPraiseUserModel * user = _showPraiseModel.praiseList[index - 1];
                    NSString * buttonTitleStr;
                    if (user == _showPraiseModel.praiseList.lastObject) {
                        buttonTitleStr = user.userNickName;
                    }else
                    {
                        buttonTitleStr = [NSString stringWithFormat:@"%@,", user.userNickName];
                    }
                    [button setTitle:buttonTitleStr forState:UIControlStateNormal];
                }else
                {
                    [button setTitle:[NSString stringWithFormat:@"%@", _showPraiseModel.praiseCount] forState:UIControlStateNormal];
                    [button setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:1];
                    button.selected = [praiseUserIdArray containsObject:UserId];
                }
            }
        }
    }
}
#pragma mark - 初始化
- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
