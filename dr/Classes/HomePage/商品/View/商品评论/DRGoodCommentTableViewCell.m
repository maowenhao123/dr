//
//  DRGoodCommentTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodCommentTableViewCell.h"
#import "DRGoodCommentView.h"

@interface DRGoodCommentTableViewCell ()

@property (nonatomic, weak) DRGoodCommentView * goodCommentView;

@end

@implementation DRGoodCommentTableViewCell

+ (DRGoodCommentTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"GoodCommentTableViewCellId";
    DRGoodCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRGoodCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    DRGoodCommentView * goodCommentView = [[DRGoodCommentView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 0)];
    self.goodCommentView = goodCommentView;
    [self addSubview:goodCommentView];
}

- (void)setModel:(DRGoodCommentModel *)model
{
    _model = model;
    
    self.goodCommentView.height = _model.cellH;
    self.goodCommentView.model = _model;
}

@end
