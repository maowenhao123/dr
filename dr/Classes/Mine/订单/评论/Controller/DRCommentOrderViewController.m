//
//  DRCommentOrderViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/6/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRCommentOrderViewController.h"
#import "DRCommentOrderTableViewCell.h"
#import "DRTextView.h"

@interface DRCommentOrderViewController ()

@property (nonatomic, weak) UIImageView *goodImageView;//商品图片
@property (nonatomic, weak) UILabel *goodNameLabel;//商品名称
@property (nonatomic, weak) UIButton *selectedEvaluateButton;
@property (nonatomic, weak) DRTextView *commentContentTV;

@end

@implementation DRCommentOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发表评价";
    [self setupChilds];
}
- (void)setupChilds
{
    //contentView
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 0)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    //商品图片
    UIImageView * goodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(DRMargin, 5, 40, 40)];
    self.goodImageView = goodImageView;
    goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    goodImageView.layer.masksToBounds = YES;
    [contentView addSubview:goodImageView];
    
    //商品名称
    UILabel * goodNameLabel = [[UILabel alloc] init];
    self.goodNameLabel = goodNameLabel;
    goodNameLabel.textColor = DRBlackTextColor;
    goodNameLabel.numberOfLines = 0;
    goodNameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
    [contentView addSubview:goodNameLabel];
    
    if (DRObjectIsEmpty(self.commentGoodModel.specification)) {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.commentGoodModel.goods.spreadPics, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }else
    {
        NSString * urlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.commentGoodModel.specification.picUrl, smallPicUrl];
        [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    if (DRStringIsEmpty(self.commentGoodModel.goods.description_)) {
        self.goodNameLabel.text = self.commentGoodModel.goods.name;
        
        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
        CGSize goodNameLabelSize = [self.goodNameLabel.text sizeWithFont:self.goodNameLabel.font maxSize:CGSizeMake(screenWidth - goodNameLabelX - DRMargin, 50)];
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, (50 - goodNameLabelSize.height) / 2, goodNameLabelSize.width, goodNameLabelSize.height);
    }else
    {
        NSMutableAttributedString * nameAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", self.commentGoodModel.goods.name, self.commentGoodModel.goods.description_]];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, _commentGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange( _commentGoodModel.goods.name.length, nameAttStr.length - _commentGoodModel.goods.name.length)];
        [nameAttStr addAttribute:NSFontAttributeName value:self.goodNameLabel.font range:NSMakeRange(0, nameAttStr.string.length)];
        self.goodNameLabel.attributedText = nameAttStr;

        CGFloat goodNameLabelX = CGRectGetMaxX(self.goodImageView.frame) + 10;
        CGSize goodNameLabelSize = [self.goodNameLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - goodNameLabelX - DRMargin, 50) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.goodNameLabel.frame = CGRectMake(goodNameLabelX, (50 - goodNameLabelSize.height) / 2, goodNameLabelSize.width, goodNameLabelSize.height);
    }

    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 50, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line1];
    
    //评价等级
    CGFloat buttonW = 100;
    CGFloat buttonH = 60;
    CGFloat buttonPadding = (screenWidth - 3 * buttonW) / 6;
    NSArray * buttonTitles = @[@"好评", @"中评", @"差评"];
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonPadding * 2 + (buttonW + buttonPadding) * i, CGRectGetMaxY(line1.frame), buttonW, buttonH);
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"evaluate%d_gray", i + 1]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"evaluate%d_light", i + 1]] forState:UIControlStateSelected];
        [button setTitle:[NSString stringWithFormat:@" %@", buttonTitles[i]] forState:UIControlStateNormal];
        [button setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        [button setTitleColor:DRViceColor forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        if (i == 0) {
            button.selected = YES;
            self.selectedEvaluateButton = button;
        }else
        {
            button.selected = NO;
        }
        [button addTarget:self action:@selector(evaluateButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
    }
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame) + buttonH, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [contentView addSubview:line2];
    
    //评论内容
    DRTextView *commentContentTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(line2.frame), screenWidth - 2 * 5, 150)];
    self.commentContentTV = commentContentTV;
    commentContentTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    commentContentTV.textColor = DRBlackTextColor;
    commentContentTV.myPlaceholder = @"亲，您对商品满意吗？您的评价会帮助我们选择更好的商品哦~";
    commentContentTV.maxLimitNums = 100;
    commentContentTV.tintColor = DRDefaultColor;
    [contentView addSubview:commentContentTV];
    contentView.height = CGRectGetMaxY(commentContentTV.frame);
    
    //评价
    UIButton * commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame) + 50, screenWidth - 2 * DRMargin, 40);
    commentButton.backgroundColor = DRDefaultColor;
    [commentButton setTitle:@"提交评价" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commentButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    commentButton.layer.masksToBounds = YES;
    commentButton.layer.cornerRadius = commentButton.height / 2;
    [commentButton addTarget:self action:@selector(commentButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commentButton];
}

- (void)evaluateButtonDidClick:(UIButton *)button
{
    if (self.selectedEvaluateButton == button) {
        return;
    }
    
    button.selected = YES;
    self.selectedEvaluateButton.selected = NO;
    self.selectedEvaluateButton = button;
}

- (void)commentButtonDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.commentContentTV.text))
    {
        [MBProgressHUD showError:@"您还未输入评价内容"];
        return;
    }
    
    NSDictionary *bodyDic_ = @{
                              @"content":self.commentContentTV.text,
                              @"level": @(self.selectedEvaluateButton.tag + 1)
                              };
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (!DRStringIsEmpty(self.commentGoodModel.orderId)) {
        [bodyDic setObject:self.commentGoodModel.orderId forKey:@"orderId"];
    }
    if (!DRStringIsEmpty(self.commentGoodModel.goods.id)) {
        [bodyDic setObject:self.commentGoodModel.goods.id forKey:@"goodsId"];
    }
    if (!DRObjectIsEmpty(self.commentGoodModel.specification)) {
        [bodyDic setObject:self.commentGoodModel.specification.id forKey:@"specificationId"];
    }
        
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B20",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"评价成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commentOrderSuccess" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

@end
