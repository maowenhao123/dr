//
//  DRSortTableViewCell.m
//  dr
//
//  Created by apple on 2017/3/14.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSortTableViewCell.h"

@interface DRSortTableViewCell ()

@property (nonatomic, weak) UILabel * label;
@property (nonatomic, weak) UIView * line;

@end

@implementation DRSortTableViewCell

+ (DRSortTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"SortTableViewCellId";
    DRSortTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRSortTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    //label
    UILabel * label = [[UILabel alloc] init];
    self.label = label;
    label.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    //分割线
    UIView * line = [[UIView alloc] init];
    self.line = line;
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.frame = CGRectMake(0, 0, self.width, self.height);
    self.line.frame = CGRectMake(0, self.height - 1, self.width, 1);
}

- (void)setModel:(DRSortModel *)model
{
    _model = model;
    self.label.text = _model.name;
}

- (void)setHaveSelected:(BOOL)haveSelected
{
    _haveSelected = haveSelected;
    if (_haveSelected) {//选中状态
        self.label.textColor = DRDefaultColor;
        self.label.backgroundColor = DRBackgroundColor;
        self.line.hidden = YES;
    }else
    {
        self.label.textColor = DRBlackTextColor;
        self.label.backgroundColor = [UIColor whiteColor];
        self.line.hidden = NO;
    }
}

@end
