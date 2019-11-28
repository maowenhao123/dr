//
//  DRGoodGroupTableViewCell.m
//  dr
//
//  Created by dahe on 2019/11/20.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRGoodGroupTableViewCell.h"
#import "DRGoodGroupView.h"

@interface DRGoodGroupTableViewCell ()

@property (nonatomic, weak) DRGoodGroupView * goodGroupView;

@end

@implementation DRGoodGroupTableViewCell

+ (DRGoodGroupTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"DRGoodGroupTableViewCellId";
    DRGoodGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRGoodGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
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
    DRGoodGroupView * goodGroupView = [[DRGoodGroupView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    self.goodGroupView = goodGroupView;
    [self addSubview:goodGroupView];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line.backgroundColor = DRWhiteLineColor;
    [self addSubview:line];
}

@end
