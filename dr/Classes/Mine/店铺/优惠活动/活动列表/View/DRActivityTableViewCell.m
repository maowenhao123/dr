//
//  DRActivityTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRActivityTableViewCell.h"
#import "DRSeckillGoodListViewController.h"
#import "DRActivityDetailView.h"

@interface DRActivityTableViewCell ()

@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * describeLabel;

@end

@implementation DRActivityTableViewCell

+ (DRActivityTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"ActivityManageTableViewCellId";
    DRActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    return  cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        self.layer.borderWidth = 1;
        self.layer.borderColor = DRGrayLineColor.CGColor;
        [self setupChildViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    CGRect f = frame;
    f.origin.x = DRMargin;
    f.size.width = frame.size.width - 2 * DRMargin;
    [super setFrame:f];
}

- (void)setupChildViews
{
    CGFloat viewW = screenWidth - 2 * DRMargin;
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 15, viewW - 2 * DRMargin, 16)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    titleLabel.textColor = DRBlackTextColor;
    [self addSubview:titleLabel];
    
    //描述
    UILabel * describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(titleLabel.frame), viewW - 2 * DRMargin, 55)];
    self.describeLabel = describeLabel;
    describeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    describeLabel.textColor = DRGrayTextColor;
    describeLabel.numberOfLines = 0;
    [self addSubview:describeLabel];
    
    //按钮
    CGFloat buttonW = viewW / 2;
    CGFloat buttonH = 49;
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonW * i, CGRectGetMaxY(describeLabel.frame), buttonW, buttonH);
        if (i == 0) {
            [button setTitle:@"查看详情" forState:UIControlStateNormal];
            [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        }else
        {
            [button setTitle:@"我要参加" forState:UIControlStateNormal];
            [button setTitleColor:DRViceColor forState:UIControlStateNormal];
        }
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(describeLabel.frame), viewW, 1)];
    line1.backgroundColor = DRGrayLineColor;
    [self addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(viewW / 2 - 0.5, CGRectGetMaxY(describeLabel.frame) + 7, 1, buttonH - 2 * 7)];
    line2.backgroundColor = DRGrayLineColor;
    [self addSubview:line2];
}

- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) {
        DRActivityDetailView * activityDetailView = [[DRActivityDetailView alloc] initWithFrame:KEY_WINDOW.bounds activityModel:self.activityModel];
        [KEY_WINDOW addSubview:activityDetailView];
    }else
    {
        DRSeckillGoodListViewController * seckillGoodListVC = [[DRSeckillGoodListViewController  alloc]init];
        seckillGoodListVC.activityId = self.activityModel.id;
        [self.viewController.navigationController pushViewController:seckillGoodListVC animated:YES];
    }
}

- (void)setActivityModel:(DRShopActivityModel *)activityModel
{
    _activityModel = activityModel;
    
    self.titleLabel.text = _activityModel.title;
    self.describeLabel.text = _activityModel.summary;
}

@end
