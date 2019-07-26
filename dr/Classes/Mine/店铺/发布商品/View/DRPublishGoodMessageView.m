//
//  DRPublishGoodMessageView.m
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRPublishGoodMessageView.h"
#import "DRAddPictureAndWordViewController.h"

@interface DRPublishGoodMessageView ()<AddMultipleImageViewDelegate, AddPictureAndWordViewControllerDelegate>

@end

@implementation DRPublishGoodMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChilds];
    }
    return self;
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //商品分类
    UIView * sortView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    sortView.backgroundColor = [UIColor whiteColor];
    [self addSubview:sortView];
    
    UILabel * sortLabel = [[UILabel alloc] init];
    sortLabel.text = @"商品分类";
    sortLabel.textColor = DRBlackTextColor;
    sortLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize sortLabelSize = [sortLabel.text sizeWithLabelFont:sortLabel.font];
    sortLabel.frame = CGRectMake(DRMargin, 0, sortLabelSize.width, DRCellH);
    [sortView addSubview:sortLabel];
    
    UITextField * sortTF = [[UITextField alloc] init];
    self.sortTF = sortTF;
    CGFloat sortTFX = CGRectGetMaxX(sortLabel.frame) + DRMargin;
    sortTF.frame = CGRectMake(sortTFX, 0, screenWidth - sortTFX - DRMargin - 7, DRCellH);
    sortTF.textColor = DRBlackTextColor;
    sortTF.textAlignment = NSTextAlignmentRight;
    sortTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    sortTF.tintColor = DRDefaultColor;
    sortTF.placeholder = @"选择";
    sortTF.userInteractionEnabled = NO;
    [sortView addSubview:sortTF];
    
    UIButton *sortBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sortBtn.frame =  CGRectMake(sortTFX, 0, screenWidth - sortTFX, DRCellH);
    [sortBtn setImageEdgeInsets:UIEdgeInsetsMake(0, sortBtn.width - DRMargin - 10, 0, 0)];
    [sortBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
    [sortBtn addTarget:self action:@selector(sortSelectPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [sortView addSubview:sortBtn];
    
    //选择分类
    DRGoodSortPickerView * sortChooseView = [[DRGoodSortPickerView alloc] init];
    self.sortChooseView = sortChooseView;
    __weak typeof(self) wself = self;
    sortChooseView.block = ^(NSDictionary * categoryDic, NSDictionary * subjectDic){
        wself.sortTF.text = [NSString stringWithFormat:@"%@ %@", categoryDic[@"name"], subjectDic[@"name"]];
        wself.categoryDic = categoryDic;
        wself.subjectDic = subjectDic;
    };
    
    //商品名称
    UIView * nameView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sortView.frame) + 9, screenWidth, DRCellH)];
    nameView.backgroundColor = [UIColor whiteColor];
    [self addSubview:nameView];
    
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"商品名称";
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize nameLabelSize = [nameLabel.text sizeWithLabelFont:nameLabel.font];
    nameLabel.frame = CGRectMake(DRMargin, 0, nameLabelSize.width, DRCellH);
    [nameView addSubview:nameLabel];
    
    UITextField * nameTF = [[UITextField alloc] init];
    self.nameTF = nameTF;
    CGFloat nameTFX = CGRectGetMaxX(nameLabel.frame) + DRMargin;
    nameTF.frame = CGRectMake(nameTFX, 0, screenWidth - nameTFX - DRMargin, DRCellH);
    nameTF.textColor = DRBlackTextColor;
    nameTF.textAlignment = NSTextAlignmentRight;
    nameTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    nameTF.tintColor = DRDefaultColor;
    nameTF.placeholder = @"请输入商品名称";
    [nameView addSubview:nameTF];
    
    //商品介绍
    UIView * descriptionView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameView.frame) + 1, screenWidth, 0)];
    descriptionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:descriptionView];
    
    UIView * descriptionLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    descriptionLine.backgroundColor = DRWhiteLineColor;
    [descriptionView addSubview:descriptionLine];
    
    UILabel * descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"商品简介";
    descriptionLabel.textColor = DRBlackTextColor;
    descriptionLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize descriptionLabelSize = [descriptionLabel.text sizeWithLabelFont:descriptionLabel.font];
    descriptionLabel.frame = CGRectMake(DRMargin, 9, descriptionLabelSize.width, descriptionLabelSize.height);
    [descriptionView addSubview:descriptionLabel];
    
    DRTextView *descriptionTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(descriptionLabel.frame) + 1, screenWidth - 2 * 5, 88)];
    self.descriptionTV = descriptionTV;
    descriptionTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    descriptionTV.textColor = DRBlackTextColor;
    descriptionTV.myPlaceholder = @"请介绍商品规格及主要卖点，例如多肉植物的大小、几头、状态、桩子情况等，不低于15个字";
    descriptionTV.tintColor = DRDefaultColor;
    [descriptionView addSubview:descriptionTV];
    descriptionView.height = CGRectGetMaxY(descriptionTV.frame);
    
    //添加图片
    DRAddMultipleImageView * addImageView = [[DRAddMultipleImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descriptionView.frame) + 1, screenWidth, 0)];
    self.addImageView = addImageView;
    addImageView.height = [addImageView getViewHeight];
    addImageView.maxImageCount = 6;
    addImageView.supportVideo = YES;
    addImageView.delegate = self;
    NSMutableAttributedString * addImageAttStr = [[NSMutableAttributedString alloc] initWithString:@"商品图片（第一张为推广图）"];
    [addImageAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, 4)];
    [addImageAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(4, addImageAttStr.length - 4)];
    addImageView.titleLabel.attributedText = addImageAttStr;
    [self addSubview:addImageView];

    UIView * addImageLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    addImageLine.backgroundColor = DRWhiteLineColor;
    [addImageView addSubview:addImageLine];

    //商品描述
    UIView * detailView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addImageView.frame), screenWidth, DRCellH)];
    self.detailView = detailView;
    detailView.backgroundColor = [UIColor whiteColor];
    [self addSubview:detailView];

    UIView * detailLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    detailLine.backgroundColor = DRWhiteLineColor;
    [detailView addSubview:detailLine];

    UILabel * detailLabel = [[UILabel alloc] init];
    NSMutableAttributedString * detailAttStr = [[NSMutableAttributedString alloc] initWithString:@"商品描述（选填）"];
    [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, 4)];
    [detailAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(4, detailAttStr.length - 4)];
    [detailAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, detailAttStr.length)];
    detailLabel.attributedText = detailAttStr;
    CGSize detailLabelSize = [detailLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth, screenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    detailLabel.frame = CGRectMake(DRMargin, 0, detailLabelSize.width, DRCellH);
    [detailView addSubview:detailLabel];

    UITextField * detailTF = [[UITextField alloc] init];
    self.detailTF = detailTF;
    CGFloat detailTFX = CGRectGetMaxX(detailLabel.frame) + DRMargin;
    detailTF.frame = CGRectMake(detailTFX, 0, screenWidth - detailTFX - DRMargin - 7, DRCellH);
    detailTF.textColor = DRBlackTextColor;
    detailTF.textAlignment = NSTextAlignmentRight;
    detailTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    detailTF.tintColor = DRDefaultColor;
    detailTF.placeholder = @"可添加图文详情介绍";
    detailTF.userInteractionEnabled = NO;
    [detailView addSubview:detailTF];

    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    detailBtn.frame =  CGRectMake(detailTFX, 0, screenWidth - detailTFX, DRCellH);
    [detailBtn setImageEdgeInsets:UIEdgeInsetsMake(0, detailBtn.width - DRMargin - 10, 0, 0)];
    [detailBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(addDetailButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [detailView addSubview:detailBtn];
    
    //售卖类型
    UIView * sellTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(detailView.frame) + 9, screenWidth, DRCellH)];
    self.sellTypeView = sellTypeView;
    sellTypeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:sellTypeView];
    
    UIView * sellTypeLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    sellTypeLine.backgroundColor = DRWhiteLineColor;
    [sellTypeView addSubview:sellTypeLine];
    
    UILabel * sellTypeTitleLabel = [[UILabel alloc] init];
    sellTypeTitleLabel.text = @"售卖类型";
    sellTypeTitleLabel.textColor = DRBlackTextColor;
    sellTypeTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize sellTypeTitleLabelSize = [sellTypeTitleLabel.text sizeWithLabelFont:sellTypeTitleLabel.font];
    sellTypeTitleLabel.frame = CGRectMake(DRMargin, 0, sellTypeTitleLabelSize.width, DRCellH);
    [sellTypeView addSubview:sellTypeTitleLabel];
    
    UILabel * sellTypeLabel = [[UILabel alloc] init];
    self.sellTypeLabel = sellTypeLabel;
    sellTypeLabel.text = @"批发";
    sellTypeLabel.textColor = DRBlackTextColor;
    sellTypeLabel.textAlignment = NSTextAlignmentRight;
    sellTypeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGFloat sellTypeLabelX = CGRectGetMaxX(sellTypeTitleLabel.frame) + DRMargin;
    sellTypeLabel.frame = CGRectMake(sellTypeLabelX, 0, screenWidth - sellTypeLabelX - DRMargin - 7, DRCellH);
    [sellTypeView addSubview:sellTypeLabel];
    
    UIButton *sellTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sellTypeBtn.frame =  CGRectMake(sellTypeLabelX, 0, screenWidth - sellTypeLabelX, DRCellH);
    [sellTypeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, sellTypeBtn.width - DRMargin - 10, 0, 0)];
    [sellTypeBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
    [sellTypeBtn addTarget:self action:@selector(sellTypeSelectPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [sellTypeView addSubview:sellTypeBtn];
    
    self.height = CGRectGetMaxY(sellTypeView.frame);
}

#pragma mark - 按钮点击
- (void)sortSelectPickerView:(UIButton *)button
{
    [self endEditing:YES];//取消其他键盘
    [self.sortChooseView show];
}

- (void)addDetailButtonDidClick
{
    [self endEditing:YES];
    
    DRAddPictureAndWordViewController * addPictureAndWordVC = [[DRAddPictureAndWordViewController alloc] init];
    addPictureAndWordVC.delegate = self;
    addPictureAndWordVC.attStr = self.detailAttStr;
    [self.viewController.navigationController pushViewController:addPictureAndWordVC animated:YES];
}

- (void)sellTypeSelectPickerView:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(sellTypeSelectPicker)]) {
        [_delegate sellTypeSelectPicker];
    }
}

- (void)addPictureAndWordWithRichTexts:(NSArray *)richTexts attStr:(NSAttributedString *)attStr
{
    self.richTexts = richTexts;
    if (richTexts.count > 0) {
        self.detailTF.placeholder = @"已编辑";
    }else
    {
        self.detailTF.placeholder = @"可添加图文详情介绍";
    }
    self.detailAttStr = attStr;
}


- (void)viewHeightchange
{
    self.detailView.y = CGRectGetMaxY(self.addImageView.frame);
    self.sellTypeView.y = CGRectGetMaxY(self.detailView.frame);
    self.height = CGRectGetMaxY(self.sellTypeView.frame);
    
    if (_delegate && [_delegate respondsToSelector:@selector(viewHeightchange)]) {
        [_delegate viewHeightchange];
    }
}


@end
