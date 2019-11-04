//
//  DRPublishSingleGoodView.m
//  dr
//
//  Created by 毛文豪 on 2018/4/10.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRPublishSingleGoodView.h"
#import "DRManageSpecificationViewController.h"
#import "DRBottomPickerView.h"
#import "UIButton+DR.h"

@interface DRPublishSingleGoodView ()<ManageSpecificationDelegate>

@property (nonatomic, weak) UIView * singleGoodMessageView;
@property (nonatomic, weak) UIView * specificationView;
@property (nonatomic, weak) UILabel * specificationLabel;

@end

@implementation DRPublishSingleGoodView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    self.backgroundColor = [UIColor whiteColor];
    
    //分割线
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [self addSubview:line1];
    
    //选择多规格
    UIButton * specificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.specificationButton = specificationButton;
    specificationButton.frame = CGRectMake(0, 0, 280, DRCellH);
    [specificationButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [specificationButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [specificationButton setTitle:@"如选择上传本商品的多规格，请勾选" forState:UIControlStateNormal];
    [specificationButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    specificationButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [specificationButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    [specificationButton addTarget:self action:@selector(specificationButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:specificationButton];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(specificationButton.frame), screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [self addSubview:line2];
    
    //商品信息
    UIView * singleGoodMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame), screenWidth, 0)];
    self.singleGoodMessageView = singleGoodMessageView;
    [self addSubview:singleGoodMessageView];
    
    //商品价格
    UILabel * priceLabel = [[UILabel alloc] init];
    priceLabel.text = @"商品价格";
    priceLabel.textColor = DRBlackTextColor;
    priceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [singleGoodMessageView addSubview:priceLabel];
    CGSize priceLabelSize = [priceLabel.text sizeWithLabelFont:priceLabel.font];
    priceLabel.frame = CGRectMake(DRMargin, 0, priceLabelSize.width, DRCellH);
    
    UILabel * symbolLabel = [[UILabel alloc] init];
    symbolLabel.text = @"元";
    symbolLabel.textColor = DRBlackTextColor;
    symbolLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [singleGoodMessageView addSubview:symbolLabel];
    CGSize symbolLabelSize = [symbolLabel.text sizeWithLabelFont:symbolLabel.font];
    symbolLabel.frame = CGRectMake(screenWidth - DRMargin - symbolLabelSize.width, 0, symbolLabelSize.width, DRCellH);
    
    DRDecimalTextField * priceTF = [[DRDecimalTextField alloc] init];
    self.priceTF = priceTF;
    priceTF.textColor = DRBlackTextColor;
    priceTF.textAlignment = NSTextAlignmentRight;
    priceTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    priceTF.tintColor = DRDefaultColor;
    priceTF.placeholder = @"请输入价格";
    CGFloat priceTFX = CGRectGetMaxX(priceLabel.frame) + DRMargin;
    priceTF.frame = CGRectMake(priceTFX, 0, symbolLabel.x - 2 - priceTFX, DRCellH);
    [singleGoodMessageView addSubview:priceTF];
    
    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(priceTF.frame), screenWidth, 1)];
    line3.backgroundColor = DRWhiteLineColor;
    [singleGoodMessageView addSubview:line3];

    //商品数量
    UILabel * countLabel = [[UILabel alloc] init];
    countLabel.text = @"商品库存";
    countLabel.textColor = DRBlackTextColor;
    countLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [singleGoodMessageView addSubview:countLabel];
    CGSize countLabelSize = [countLabel.text sizeWithLabelFont:countLabel.font];
    countLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(line3.frame), countLabelSize.width, DRCellH);
    
    UITextField * countTF = [[UITextField alloc] init];
    self.countTF = countTF;
    CGFloat countTFX = CGRectGetMaxX(countLabel.frame) + DRMargin;
    countTF.frame = CGRectMake(countTFX, CGRectGetMaxY(line3.frame), screenWidth - countTFX - DRMargin, DRCellH);
    countTF.textColor = DRBlackTextColor;
    countTF.textAlignment = NSTextAlignmentRight;
    countTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    countTF.tintColor = DRDefaultColor;
    countTF.keyboardType = UIKeyboardTypeNumberPad;
    countTF.placeholder = @"请输入商品库存";
    [singleGoodMessageView addSubview:countTF];
    singleGoodMessageView.height = CGRectGetMaxY(countTF.frame);
    
    self.height = CGRectGetMaxY(singleGoodMessageView.frame);
    
    //多规格
    UIView * specificationView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line2.frame), screenWidth, DRCellH)];
    self.specificationView = specificationView;
    specificationView.hidden = YES;
    [self addSubview:specificationView];
    
    UILabel * specificationTitleLabel = [[UILabel alloc] init];
    specificationTitleLabel.text = @"规格管理";
    specificationTitleLabel.textColor = DRBlackTextColor;
    specificationTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize specificationTitleLabelSize = [specificationTitleLabel.text sizeWithLabelFont:specificationTitleLabel.font];
    specificationTitleLabel.frame = CGRectMake(DRMargin, 0, specificationTitleLabelSize.width, DRCellH);
    [specificationView addSubview:specificationTitleLabel];
    
    UILabel * specificationLabel = [[UILabel alloc] init];
    self.specificationLabel = specificationLabel;
    specificationLabel.text = @"可添加商品规格";
    specificationLabel.textColor = DRGrayTextColor;
    specificationLabel.textAlignment = NSTextAlignmentRight;
    specificationLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGFloat specificationLabelX = CGRectGetMaxX(specificationTitleLabel.frame) + DRMargin;
    specificationLabel.frame = CGRectMake(specificationLabelX, 0, screenWidth - specificationLabelX - DRMargin - 7, DRCellH);
    [specificationView addSubview:specificationLabel];
    
    UIButton *specificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    specificationBtn.frame =  CGRectMake(specificationLabelX, 0, screenWidth - specificationLabelX, DRCellH);
    [specificationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, specificationBtn.width - DRMargin - 10, 0, 0)];
    [specificationBtn setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
    [specificationBtn addTarget:self action:@selector(specificationBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [specificationView addSubview:specificationBtn];
}

- (void)specificationButtonDidClick
{
    self.specificationButton.selected = !self.specificationButton.selected;
    
    if (self.specificationButton.selected) {
        self.specificationView.hidden = NO;
        self.singleGoodMessageView.hidden = YES;
        self.height = CGRectGetMaxY(self.specificationView.frame);
    }else
    {
        self.specificationView.hidden = YES;
        self.singleGoodMessageView.hidden = NO;
        self.height = CGRectGetMaxY(self.singleGoodMessageView.frame);
    }
    
    if (self.hightChangeBlock) {
        self.hightChangeBlock();
    }
    
    if (self.specificationDataArray.count > 0) {
        self.specificationLabel.text = @"已添加";
    }else
    {
        self.specificationLabel.text = @"可添加商品规格";
    }
}

- (void)specificationBtnDidClick
{
    DRManageSpecificationViewController * manageSpecificationVC = [[DRManageSpecificationViewController alloc] init];
    manageSpecificationVC.delegate = self;
    manageSpecificationVC.dataArray = self.specificationDataArray;
    [self.viewController.navigationController pushViewController:manageSpecificationVC animated:YES];
}

- (void)addSpecificationWithDataArray:(NSMutableArray *)dataArray
{
    self.specificationDataArray = dataArray;
    if (dataArray.count > 0) {
        self.specificationLabel.text = @"已添加";
    }else
    {
        self.specificationLabel.text = @"可添加商品规格";
    }
}

#pragma mark - 初始化
- (NSMutableArray *)specificationDataArray
{
    if (!_specificationDataArray) {
        _specificationDataArray = [NSMutableArray array];
    }
    return _specificationDataArray;
}


@end
