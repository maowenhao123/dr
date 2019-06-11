//
//  DRPraiseMyAwardTableViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseMyAwardTableViewCell.h"

@interface DRPraiseMyAwardTableViewCell ()

@property (nonatomic, weak) UIView *weekView;
@property (nonatomic, weak) UILabel *weekLabel;
@property (nonatomic, weak) UILabel *resultLabel;
@property (nonatomic, weak) UIButton *redPacketAwardButton;
@property (nonatomic, weak) UIButton *goodAwardButton;
@property (nonatomic, weak) UIView *redPacketAwardView;
@property (nonatomic, weak) UIView *goodAwardView;

@end

@implementation DRPraiseMyAwardTableViewCell

+ (DRPraiseMyAwardTableViewCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"PraiseMyAwardTableViewCellId";
    DRPraiseMyAwardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[DRPraiseMyAwardTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    //周
    UIView *weekView = [[UIView alloc] init];
    self.weekView = weekView;
    [self addSubview:weekView];
    
    CGFloat dotViewWH = 14;
    UIView * dotView = [[UIView alloc] initWithFrame:CGRectMake(15, 18, dotViewWH, dotViewWH)];
    dotView.backgroundColor = DRViceColor;
    dotView.layer.masksToBounds = YES;
    dotView.layer.cornerRadius = dotViewWH / 2;
    [weekView addSubview:dotView];
    
    UILabel * weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dotView.frame) + 5, 15, screenWidth - 2 * 15, 20)];
    self.weekLabel = weekLabel;
    weekLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    weekLabel.textColor = DRBlackTextColor;
    [weekView addSubview:weekLabel];
    
    //结果
    UILabel * resultLabel = [[UILabel alloc] init];
    self.resultLabel = resultLabel;
    resultLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(30)];
    resultLabel.textColor = DRGrayTextColor;
    [self addSubview:resultLabel];
    
    //奖励
    CGFloat awardBackImageViewW = 140;
    CGFloat awardBackImageViewH = 40;
    CGFloat awardButtonW = 80;
    CGFloat awardButtonH = 40;
    for (int i = 0; i < 2; i++) {
        UIView *awardView = [[UIView alloc] init];
        if (i == 0) {
            self.redPacketAwardView = awardView;
        }else if (i == 1)
        {
            self.goodAwardView = awardView;
        }
        [self addSubview:awardView];
        
        UIImageView * awardBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, awardBackImageViewW, awardBackImageViewH)];
        awardBackImageView.image = [UIImage imageNamed:@"praise_award_back"];
        [awardView addSubview:awardBackImageView];
        
        UILabel * awardLabel = [[UILabel alloc] initWithFrame:awardBackImageView.bounds];
        awardLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(30)];
        awardLabel.textColor = [UIColor whiteColor];
        awardLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:@"50元红包组合"];
            [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DRGetFontSize(36)] range:NSMakeRange(0, 2)];
            [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(30)] range:NSMakeRange(2, attStr.string.length - 2)];
            awardLabel.attributedText = attStr;
        }else if(i == 1)
        {
            awardLabel.text = @"精品多肉一盆";
        }
        [awardBackImageView addSubview:awardLabel];
        
        UIButton * awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            self.redPacketAwardButton = awardButton;
        }else if (i == 1)
        {
            self.goodAwardButton = awardButton;
        }
        awardButton.tag = i;
        awardButton.frame =CGRectMake(CGRectGetMaxX(awardBackImageView.frame) + 15, 10, awardButtonW, awardButtonH);
        [awardButton setTitle:@"领取" forState:UIControlStateNormal];
        [awardButton setTitleColor:DRPraiseRedTextColor forState:UIControlStateNormal];
        awardButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        awardButton.layer.masksToBounds = YES;
        awardButton.layer.cornerRadius = 2;
        awardButton.layer.borderColor = DRPraiseRedTextColor.CGColor;
        awardButton.layer.borderWidth = 1;
        [awardButton addTarget:self action:@selector(awardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [awardView addSubview:awardButton];
    }
}

- (void)awardButtonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(praiseMyAwardTableViewCell:awardButtonDidClick:)]) {
        [_delegate praiseMyAwardTableViewCell:self awardButtonDidClick:button];
    }
}

- (void)setAwardSectionModel:(DRPraiseSectionModel *)awardSectionModel
{
    _awardSectionModel = awardSectionModel;
    
    self.weekLabel.text = _awardSectionModel.cycle;
    if (_awardSectionModel.awardList.count > 0) {
        self.resultLabel.text = @"以下奖励二选一";
    }else
    {
        long long endCycle = _awardSectionModel.endCycle;
        if (endCycle == 0) {
            endCycle = _awardSectionModel.endTime;
        }
        if (endCycle < self.systemTime) {
            self.resultLabel.text = @"您未能中奖";
        }else
        {
            self.resultLabel.text = @"未派奖";
        }
    }
    
    DRAwardModel *awardModel = _awardSectionModel.awardList.firstObject;
    if ([awardModel.receiveType intValue] == 1) {//1领取多肉 2红包
        [self.redPacketAwardButton setTitle:@"领取" forState:UIControlStateNormal];
        [self.goodAwardButton setTitle:@"查物流" forState:UIControlStateNormal];
    }else if ([awardModel.receiveType intValue] == 2)
    {
        [self.redPacketAwardButton setTitle:@"查看" forState:UIControlStateNormal];
        [self.goodAwardButton setTitle:@"领取" forState:UIControlStateNormal];
    }else
    {
        [self.redPacketAwardButton setTitle:@"领取" forState:UIControlStateNormal];
        [self.goodAwardButton setTitle:@"领取" forState:UIControlStateNormal];
    }
    
    [self setViewFrameWithView:self.weekView frame:_awardSectionModel.weekViewF];
    [self setViewFrameWithView:self.resultLabel frame:_awardSectionModel.resultLabelF];
    [self setViewFrameWithView:self.redPacketAwardView frame:_awardSectionModel.redPacketAwardViewF];
    [self setViewFrameWithView:self.goodAwardView frame:_awardSectionModel.goodAwardViewF];
}

- (void)setViewFrameWithView:(UIView *)view frame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        view.hidden = YES;
    }else
    {
        view.hidden = NO;
        view.frame = frame;
    }
}

@end
