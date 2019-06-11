//
//  DRPraiseGoodAwardCollectionViewCell.m
//  dr
//
//  Created by 毛文豪 on 2018/12/25.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseGoodAwardCollectionViewCell.h"
#import "DRPraiseAwardAddressViewController.h"

@interface DRPraiseGoodAwardCollectionViewCell ()

@property (nonatomic, weak) UIImageView *goodImageView;
@property (nonatomic, weak) UIButton *chooseGoodButton;

@end

@implementation DRPraiseGoodAwardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    CGFloat width = (screenWidth - 30) / 2;
    //图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [self addSubview:goodImageView];
    
    //选它
    UIButton * awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    awardButton.frame = CGRectMake(0, CGRectGetMaxY(goodImageView.frame) + 5, width, 40);
    [awardButton setTitle:@"选它" forState:UIControlStateNormal];
    [awardButton setTitleColor:DRPraiseRedTextColor forState:UIControlStateNormal];
    awardButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(32)];
    awardButton.layer.masksToBounds = YES;
    awardButton.layer.cornerRadius = 2;
    awardButton.layer.borderColor = DRPraiseRedTextColor.CGColor;
    awardButton.layer.borderWidth = 1;
    [awardButton addTarget:self action:@selector(awardButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:awardButton];
}

- (void)awardButtonDidClick:(UIButton *)button
{
    DRPraiseAwardAddressViewController * awardAddressVC = [[DRPraiseAwardAddressViewController alloc] init];
    awardAddressVC.goodsId = self.goodAwardModel.id;
    awardAddressVC.activityId = self.activityId;
    awardAddressVC.type = self.type;
    [self.viewController.navigationController pushViewController:awardAddressVC animated:YES];
}

- (void)setGoodAwardModel:(DRPraiseGoodAwardModel *)goodAwardModel
{
    _goodAwardModel = goodAwardModel;
    
    NSString * imageUrlStr = [NSString stringWithFormat:@"%@%@", baseUrl, _goodAwardModel.image];
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

@end
