//
//  DRPublishGoodViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/4/8.
//  Copyright © 2018年 JG. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "DRPublishGoodViewController.h"
#import "DRAddPictureAndWordViewController.h"
#import "DRGoodSortPickerView.h"
#import "DRPublishWholesaleGoodView.h"
#import "DRPublishSingleGoodView.h"
#import "DRTextView.h"
#import "DRAddMultipleImageView.h"
#import "DRBottomPickerView.h"

@interface DRPublishGoodViewController ()<AddMultipleImageViewDelegate, AddPictureAndWordViewControllerDelegate>

@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic, weak) UIView * goodMessageView;
@property (nonatomic, weak) UITextField * sortTF;
@property (nonatomic, weak) DRGoodSortPickerView * sortChooseView;
@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) DRTextView *descriptionTV;//简介输入
@property (nonatomic, weak) DRAddMultipleImageView * addImageView;
@property (nonatomic, weak) UIView * detailView;
@property (nonatomic, weak) UITextField * detailTF;
@property (nonatomic, weak) UIView * sellTypeView;
@property (nonatomic, weak) UILabel * sellTypeLabel;
@property (nonatomic, weak) DRPublishSingleGoodView * singleView;
@property (nonatomic, weak) DRPublishWholesaleGoodView * wholesaleView;
@property (nonatomic, weak) UIButton * confirmBtn;
@property (nonatomic,strong) NSArray *richTexts;
@property (nonatomic,copy) NSAttributedString *detailAttStr;
@property (nonatomic, strong) NSDictionary * categoryDic;
@property (nonatomic, strong) NSDictionary * subjectDic;
@property (nonatomic,strong) DRGoodModel *goodModel;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;
@property (nonatomic, copy) NSString *uploadVideoUrl;

@end

@implementation DRPublishGoodViewController

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 设置背景
    [navBar setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发布商品";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    if (!Token || !UserId || !self.goodId) {
        return;
    }
    NSDictionary *bodyDic = @{
                              @"id":self.goodId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B08",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRGoodModel * goodModel = [DRGoodModel mj_objectWithKeyValues:json[@"goods"]];
            self.goodModel = goodModel;
            [self setData];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];;
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //scrollView
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    scrollView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:scrollView];
    
    //商品分类
    UIView * sortView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    sortView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:sortView];
    
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

    //商品信息
    UIView * goodMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sortView.frame) + 9, screenWidth, 0)];
    self.goodMessageView = goodMessageView;
    goodMessageView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:goodMessageView];
    
    //商品名称
    UIView * nameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, DRCellH)];
    nameView.backgroundColor = [UIColor whiteColor];
    [goodMessageView addSubview:nameView];
    
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
    [goodMessageView addSubview:descriptionView];
    
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
    descriptionTV.myPlaceholder = @"请介绍商品的主要卖点或商品规格";
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
    [goodMessageView addSubview:addImageView];
    
    UIView * addImageLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    addImageLine.backgroundColor = DRWhiteLineColor;
    [addImageView addSubview:addImageLine];
    
    //商品描述
    UIView * detailView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(addImageView.frame), screenWidth, DRCellH)];
    self.detailView = detailView;
    detailView.backgroundColor = [UIColor whiteColor];
    [goodMessageView addSubview:detailView];
    
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
    
    goodMessageView.height = CGRectGetMaxY(detailView.frame);
    
    //售卖类型
    UIView * sellTypeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(goodMessageView.frame) + 9, screenWidth, 0)];
    self.sellTypeView = sellTypeView;
    sellTypeView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:sellTypeView];
    
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
    
    //一物一拍/零售
    DRPublishSingleGoodView * singleView = [[DRPublishSingleGoodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sellTypeTitleLabel.frame), screenWidth, 0)];
    self.singleView = singleView;
    singleView.hidden = YES;
    [sellTypeView addSubview:singleView];
    
    //批发
    DRPublishWholesaleGoodView * wholesaleView = [[DRPublishWholesaleGoodView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(sellTypeTitleLabel.frame), screenWidth, 0)];
    self.wholesaleView = wholesaleView;
    wholesaleView.block = ^{
        wself.sellTypeView.height = CGRectGetMaxY(wself.wholesaleView.frame);
        wself.confirmBtn.y = CGRectGetMaxY(self.sellTypeView.frame) + 29;
        wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
    };
    [sellTypeView addSubview:wholesaleView];
    sellTypeView.height = CGRectGetMaxY(wholesaleView.frame);
    
    //确定按钮
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmBtn = confirmBtn;
    confirmBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(sellTypeView.frame) + 29, screenWidth - 2 * DRMargin, 40);
    confirmBtn.backgroundColor = DRDefaultColor;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = confirmBtn.height / 2;
    [scrollView addSubview:confirmBtn];
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(confirmBtn.frame) + 10);
}

- (void)viewHeightchange
{
    self.detailView.y = CGRectGetMaxY(self.addImageView.frame);
    self.goodMessageView.height = CGRectGetMaxY(self.detailView.frame);
    self.sellTypeView.y = CGRectGetMaxY(self.goodMessageView.frame) + 9;
    self.confirmBtn.y = CGRectGetMaxY(self.sellTypeView.frame) + 29;
    self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
}

#pragma mark - 按钮点击
- (void)sortSelectPickerView:(UIButton *)button
{
    [self.view endEditing:YES];//取消其他键盘
    [self.sortChooseView show];
}

- (void)addDetailButtonDidClick
{
    [self.view endEditing:YES];
    
    DRAddPictureAndWordViewController * addPictureAndWordVC = [[DRAddPictureAndWordViewController alloc] init];
    addPictureAndWordVC.delegate = self;
    addPictureAndWordVC.attStr = self.detailAttStr;
    [self.navigationController pushViewController:addPictureAndWordVC animated:YES];
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

- (void)sellTypeSelectPickerView:(UIButton *)button
{
    [self.view endEditing:YES];//取消其他键盘
    //选择销售类型
    NSArray * sellTypes = @[@"一物一拍/零售", @"批发"];
    NSInteger index = [sellTypes indexOfObject:self.sellTypeLabel.text];
    if (DRStringIsEmpty(self.sellTypeLabel.text)) {
        index = 0;
    }
    DRBottomPickerView * sellTypeChooseView = [[DRBottomPickerView alloc] initWithArray:sellTypes index:index];
    __weak typeof(self) wself = self;
    sellTypeChooseView.block = ^(NSInteger selectedIndex){
        wself.sellTypeLabel.text = sellTypes[selectedIndex];
        if (selectedIndex == 0) {//一物一拍/零售
            wself.singleView.hidden = NO;
            wself.wholesaleView.hidden = YES;
            wself.sellTypeView.height = CGRectGetMaxY(wself.singleView.frame);
        }else//批发
        {
            wself.singleView.hidden = YES;
            wself.wholesaleView.hidden = NO;
            wself.sellTypeView.height = CGRectGetMaxY(wself.wholesaleView.frame);
        }
        wself.confirmBtn.y = CGRectGetMaxY(self.sellTypeView.frame) + 29;
        wself.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
    };
    [sellTypeChooseView show];
}

#pragma mark - 设置数据
- (void)setData
{
    self.title = @"编辑商品";
    self.nameTF.text = self.goodModel.name;
    self.sortTF.text = [NSString stringWithFormat:@"%@ %@", self.goodModel.categoryName, self.goodModel.subjectName];
    self.descriptionTV.text = self.goodModel.description_;
    
    if (!DRStringIsEmpty(self.goodModel.categoryId) && !DRStringIsEmpty(self.goodModel.categoryName)) {
        NSDictionary *categoryDic = @{
                                      @"name":self.goodModel.categoryName,
                                      @"id":self.goodModel.categoryId
                                      };
        self.categoryDic = categoryDic;
    }
    
    if (!DRStringIsEmpty(self.goodModel.subjectId) && !DRStringIsEmpty(self.goodModel.subjectName)) {
        NSDictionary *subjectDic = @{
                                     @"name":self.goodModel.subjectName,
                                     @"id":self.goodModel.subjectId
                                     };
        self.subjectDic = subjectDic;
    }
    
    //图文
    if (self.goodModel.richTexts.count > 0) {
        self.detailTF.placeholder = @"已编辑";
        NSMutableAttributedString *detailAttStr = [[NSMutableAttributedString alloc] init];
        BOOL firstPic = YES;
        for (NSDictionary * richText in self.goodModel.richTexts) {
            if ([richText[@"type"] intValue] == 1) {//图片
                if (firstPic) {
                    [detailAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                }
                NSURL * imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, richText[@"content"]]];
                NSData * imageData=[NSData dataWithContentsOfURL:imageUrl];
                UIImage * image = [UIImage imageWithData:imageData];
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
                CGFloat textAttachmentW = screenWidth - 2 * 5;
                CGFloat textAttachmentH = textAttachmentW * (image.size.height / image.size.width);
                textAttachment.bounds = CGRectMake(5, 0, textAttachmentW , textAttachmentH);
                textAttachment.image = image;
                NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [detailAttStr appendAttributedString:textAttachmentString];
                [detailAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                firstPic = NO;
            }else//文字
            {
                NSMutableAttributedString *textAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", richText[@"content"]]];
                [textAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(28)] range:NSMakeRange(0, textAttStr.length)];
                [textAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:NSMakeRange(0, textAttStr.length)];
                [detailAttStr appendAttributedString:textAttStr];
            }
        }
        self.detailAttStr = detailAttStr;
    }
    [MBProgressHUD hideHUDForView:self.view];
    
    if ([self.goodModel.sellType intValue] == 1)//一物一拍/零售
    {
        self.sellTypeLabel.text = @"一物一拍/零售";
        self.singleView.hidden = NO;
        self.wholesaleView.hidden = YES;
        self.sellTypeView.height = CGRectGetMaxY(self.singleView.frame);
        
        self.singleView.priceTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.goodModel.price doubleValue] / 100]];
        //plusCount
        self.singleView.countTF.text = [NSString stringWithFormat:@"%@", self.goodModel.plusCount];
    }else//批发
    {
        self.sellTypeLabel.text = @"批发";
        self.singleView.hidden = YES;
        self.wholesaleView.hidden = NO;
        self.sellTypeView.height = CGRectGetMaxY(self.wholesaleView.frame);
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO];
        NSArray *wholesaleRule = [self.goodModel.wholesaleRule sortedArrayUsingDescriptors:@[sortDescriptor]];//排序
        for (int i = 0; i < wholesaleRule.count; i++) {
            NSDictionary * wholesaleRuleDic = wholesaleRule[i];
            if (i == 0) {
                self.wholesaleView.priceTF1.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF1.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }else if (i == 1)
            {
                self.wholesaleView.priceTF2.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF2.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }else if (i == 2)
            {
                self.wholesaleView.priceTF3.text = [NSString stringWithFormat:@"%@",[DRTool formatFloat:[wholesaleRuleDic[@"price"] doubleValue] / 100]];
                self.wholesaleView.numberTF3.text = [NSString stringWithFormat:@"%@",wholesaleRuleDic[@"count"]];
            }
        }
        self.wholesaleView.priceTF.text = [NSString stringWithFormat:@"%@", [DRTool formatFloat:[self.goodModel.agentPrice doubleValue] / 100]];
        self.wholesaleView.countTF.text = [NSString stringWithFormat:@"%@", self.goodModel.plusCount];
 
        self.wholesaleView.isGroup = self.goodModel.isGroup;
    }
    self.confirmBtn.y = CGRectGetMaxY(self.sellTypeView.frame) + 29;
    self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.confirmBtn.frame) + 10);
    
    NSMutableArray * imageUrlStrs = [NSMutableArray array];
    if (!DRStringIsEmpty(self.goodModel.spreadPics)) {
        [imageUrlStrs addObject:self.goodModel.spreadPics];
    }
    
    if (!DRStringIsEmpty(self.goodModel.morePics)) {
        NSArray * morePics = [self.goodModel.morePics componentsSeparatedByString:@"|"];
        if (!DRArrayIsEmpty(morePics)) {
            [imageUrlStrs addObjectsFromArray:morePics];
        }
    }
    if (!DRArrayIsEmpty(imageUrlStrs)) {
        NSLog(@"%@", imageUrlStrs);
        [self.addImageView setImagesWithImageUrlStrs:imageUrlStrs];
    }
    if (!DRStringIsEmpty(self.goodModel.video)) {
        self.addImageView.videoURL = [NSURL URLWithString:self.goodModel.video];
    }
}

#pragma mark - 发布商品
- (void)confirmBtnDidClick
{
    [self.view endEditing:YES];
//    [self uploadVideo];
//    return;
    //判空
    if (DRStringIsEmpty(self.sortTF.text)) {
        [MBProgressHUD showError:@"未输入商品分类"];
        return;
    }
    
    if (DRStringIsEmpty(self.nameTF.text)) {
        [MBProgressHUD showError:@"未输入商品名称"];
        return;
    }
    
    if (DRStringIsEmpty(self.descriptionTV.text)) {
        [MBProgressHUD showError:@"未输入商品简介"];
        return;
    }
    
    if (DRArrayIsEmpty(self.addImageView.images)) {
        [MBProgressHUD showError:@"请至少上传一张图片"];
        return;
    }
    
    if ([self.sellTypeLabel.text isEqualToString:@"一物一拍/零售"]) {//一物一拍/零售
        if (DRStringIsEmpty(self.singleView.priceTF.text)) {
            [MBProgressHUD showError:@"未输入商品价格"];
            return;
        }
        if (DRStringIsEmpty(self.singleView.countTF.text)) {
            [MBProgressHUD showError:@"未输入商品库存"];
            return;
        }
    }else
    {
        double priceFloat1 = [self.wholesaleView.priceTF1.text doubleValue];
        double priceFloat2 = [self.wholesaleView.priceTF2.text doubleValue];
        double priceFloat3 = [self.wholesaleView.priceTF3.text doubleValue];
        int numberInt1 = [self.wholesaleView.numberTF1.text intValue];
        int numberInt2 = [self.wholesaleView.numberTF2.text intValue];
        int numberInt3 = [self.wholesaleView.numberTF3.text intValue];
        
        if ((DRStringIsEmpty(self.wholesaleView.priceTF1.text) || DRStringIsEmpty(self.wholesaleView.numberTF1.text)) && (DRStringIsEmpty(self.wholesaleView.priceTF2.text) || DRStringIsEmpty(self.wholesaleView.numberTF2.text)) && (DRStringIsEmpty(self.wholesaleView.priceTF3.text) || DRStringIsEmpty(self.wholesaleView.numberTF3.text))) {
            [MBProgressHUD showError:@"未输入批发规则"];
            return;
        }
        if ((priceFloat2 > 0 && priceFloat2 == priceFloat1) || (priceFloat3 > 0 && priceFloat3 == priceFloat2) || (priceFloat3 > 0 && priceFloat3 == priceFloat1)) {
            [MBProgressHUD showError:@"批发规则不正确"];
            return;
        }
        if ((numberInt1 > 0 && numberInt2 == numberInt1) || (numberInt3 > 0 && priceFloat3 == numberInt2) || (numberInt3 > 0 && numberInt3 == numberInt1)) {
            [MBProgressHUD showError:@"批发规则不正确"];
            return;
        }
        
        if (DRStringIsEmpty(self.wholesaleView.countTF.text)) {
            [MBProgressHUD showError:@"未输入商品库存"];
            return;
        }
    }
    
    if (self.addImageView.videoURL && ![self.addImageView.videoURL.absoluteString containsString:@"http"]) {
        [self uploadVideo];
    }else
    {
        if (!self.addImageView.videoURL) {
            self.uploadVideoUrl = @"-1";
        }
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadImageWithImage:self.addImageView.images[0]];
    }
}

- (void)uploadVideo
{
    [DRHttpTool upFileWithVideo:self.addImageView.videoURL Success:^(id json) {
        if (SUCCESS) {
            self.uploadVideoUrl = json[@"picUrl"];
        }
        
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadImageWithImage:self.addImageView.images[0]];
    } Failure:^(NSError *error) {
        
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadImageWithImage:self.addImageView.images[0]];
    } Progress:^(float percent) {
        
    }];
}

- (void)uploadImageWithImage:(UIImage *)image
{
    [DRHttpTool uploadWithImage:image currentIndex:[self.addImageView.images indexOfObject:image] + 1 totalCount:self.addImageView.images.count Success:^(id json) {
        if (SUCCESS) {
            [self.uploadImageUrlArray addObject:json[@"picUrl"]];
        }else
        {
            [self.uploadImageUrlArray addObject:@""];
        }
        if (self.uploadImageUrlArray.count == self.addImageView.images.count)
        {
            [self uploadGood];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == self.addImageView.images.count)
        {
            [self uploadGood];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Progress:^(float percent) {
        
    }];
}

- (void)uploadGood
{
    NSDictionary * bodyDic_ = [NSDictionary dictionary];
    NSString *categoryId = self.categoryDic[@"id"];
    NSString *subjectId = self.subjectDic[@"id"];
    
    if ([self.sellTypeLabel.text isEqualToString:@"一物一拍/零售"]) {//一物一拍/零售
        NSNumber * priceStr = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.singleView.priceTF.text doubleValue]]];
        bodyDic_ = @{
                     @"price":priceStr,
                     @"count":self.singleView.countTF.text,
                     @"description":self.descriptionTV.text,
                     @"goodsName":self.nameTF.text,
                     @"sellType":@(1),
                     @"picUrls":self.uploadImageUrlArray,
                     @"categoryId":categoryId,
                     @"subjectId":subjectId,
                     };
    }else//批发
    {
        //批发规则
        NSMutableArray * wholesaleRule = [NSMutableArray array];
        if (!DRStringIsEmpty(self.wholesaleView.priceTF1.text) && !DRStringIsEmpty(self.wholesaleView.numberTF1.text)) {
            NSNumber * priceStr1 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF1.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr1,
                                   @"count":self.wholesaleView.numberTF1.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        
        if (!DRStringIsEmpty(self.wholesaleView.priceTF2.text) && !DRStringIsEmpty(self.wholesaleView.numberTF2.text)) {
            NSNumber * priceStr2 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF2.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr2,
                                   @"count":self.wholesaleView.numberTF2.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        
        if (!DRStringIsEmpty(self.wholesaleView.priceTF3.text) && !DRStringIsEmpty(self.wholesaleView.numberTF3.text)) {
            NSNumber * priceStr3 = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.wholesaleView.priceTF3.text doubleValue]]];
            NSDictionary * dic = @{
                                   @"price":priceStr3,
                                   @"count":self.wholesaleView.numberTF3.text,
                                   };
            [wholesaleRule addObject:dic];
        }
        bodyDic_ = @{
                     @"wholesaleRule":wholesaleRule,
                     @"description":self.descriptionTV.text,
                     @"goodsName":self.nameTF.text,
                     @"sellType":@(2),
                     @"picUrls":self.uploadImageUrlArray,
                     @"categoryId":categoryId,
                     @"subjectId":subjectId,
                     @"count":self.wholesaleView.countTF.text,
                     };
        
    }
    NSMutableDictionary * bodyDic = [NSMutableDictionary dictionaryWithDictionary:bodyDic_];
    if (self.goodModel) {
        [bodyDic setObject:self.goodModel.id forKey:@"id"];
    }
    if (!DRArrayIsEmpty(self.richTexts)) {
        [bodyDic setObject:self.richTexts forKey:@"richTexts"];
    }
   
    if ([self.sellTypeLabel.text isEqualToString:@"批发"] && self.wholesaleView.isGroup == 1) {
        NSNumber * isGroup = [NSNumber numberWithInt:self.wholesaleView.isGroup];
        [bodyDic setObject:isGroup forKey:@"isGroup"];
    }
    if (self.addImageView.videoURL) {
        int videoTime = [DRTool getVideoTimeWithSourcevideoURL:self.addImageView.videoURL] * 1000;
        [bodyDic setObject:@(videoTime) forKey:@"videoTime"];
    }
    if (!DRStringIsEmpty(self.uploadVideoUrl)) {
        if ([self.uploadVideoUrl isEqualToString:@"-1"]) {
            [bodyDic setObject:@"" forKey:@"video"];
            [bodyDic setObject:@"" forKey:@"videoTime"];
        }else
        {
            [bodyDic setObject:self.uploadVideoUrl forKey:@"video"];
        }
    }
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B06",
                              @"userId":UserId,
                              };
    [MBProgressHUD showMessage:@"上传商品中" toView:self.view];
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@", json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"上传成功"];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addGoodSuccess" object:nil];
        }else
        {
            [MBProgressHUD hideHUDForView:self.view];
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSMutableArray *)uploadImageUrlArray
{
    if (!_uploadImageUrlArray) {
        _uploadImageUrlArray = [NSMutableArray array];
    }
    return _uploadImageUrlArray;
}

@end
