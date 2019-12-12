//
//  DRIdentityAuditViewController.m
//  dr
//
//  Created by dahe on 2019/8/15.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRIdentityAuditViewController.h"
#import "DRCardNoTextField.h"
#import "DRAddImageManage.h"
#import "DRAddMultipleImageView.h"
#import "DRValidateTool.h"
#import "UIButton+DR.h"

@interface DRIdentityAuditViewController ()<AddImageManageDelegate, AddMultipleImageViewDelegate>

@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic, weak) UITextField * realNameTF;
@property (nonatomic, weak) UITextField * personalIdTF;
@property (nonatomic,weak) UIImageView * imageView1;
@property (nonatomic,weak) UIImageView * imageView2;
@property (nonatomic, strong) DRAddImageManage * addImageManage;
@property (nonatomic,weak) UIView * typeView;
@property (nonatomic,weak) UIButton * typeSelectedButton;
@property (nonatomic,weak) UIView * baseView;
@property (nonatomic, weak) DRAddMultipleImageView * addImageView;
@property (nonatomic, weak) UITextField * addressTF;
@property (nonatomic,weak) UIView *agreementView;
@property (nonatomic,weak) UIButton *agreementButton;
@property (nonatomic,assign) BOOL haveImage1;
@property (nonatomic,assign) BOOL haveImage2;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;

@end

@implementation DRIdentityAuditViewController

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
    self.title = @"实名认证";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交审核" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    //scrollView
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.scrollView = scrollView;
    scrollView.backgroundColor = DRBackgroundColor;
    [self.view addSubview:scrollView];
    
    UIView * contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 9, screenWidth, 2 * DRCellH + 170);
    contentView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contentView];
    
    NSArray * titles = @[@"真实姓名",@"身份证号"];
    for (int i = 0; i < 2; i++) {
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.text = titles[i];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin,i * DRCellH, titleLabelSize.width, DRCellH);
        [contentView addSubview:titleLabel];
        
        UITextField * textField;
        if (i == 0) {
            textField = [[UITextField alloc] init];
        }else
        {
            textField = [[DRCardNoTextField alloc] init];
        }
        textField.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + DRMargin, i * DRCellH, screenWidth - 2 * DRMargin - CGRectGetMaxX(titleLabel.frame), DRCellH);
        textField.textAlignment = NSTextAlignmentRight;
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        [scrollView addSubview:textField];
        if (i == 0) {
            textField.placeholder = @"请输入真实姓名";
            self.realNameTF = textField;
        }else if (i == 1)
        {
            textField.placeholder = @"请输入身份证号码";
            self.personalIdTF = textField;
        }
        [contentView addSubview:textField];
        //分割线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, (DRCellH - 1) * i + DRCellH, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line];
    }
    
    UILabel * pictureLabel = [[UILabel alloc]init];
    pictureLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    pictureLabel.textColor = DRBlackTextColor;
    pictureLabel.text = @"上传身份证照片";
    CGSize titleLabelSize = [pictureLabel.text sizeWithLabelFont:pictureLabel.font];
    pictureLabel.frame = CGRectMake(DRMargin, 2 * DRCellH + 5, titleLabelSize.width, 25);
    [contentView addSubview:pictureLabel];
    
    CGFloat imageViewY = CGRectGetMaxY(pictureLabel.frame) + 5;
    CGFloat imageViewHW = 100;
    CGFloat padding = (screenWidth - 2 * imageViewHW) / 3;
    NSArray * pictureTitles = @[@"身份证正面",@"身份证反面"];
    for (int i = 0; i < 2; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        if (i == 0) {
            self.imageView1 = imageView;
        }else
        {
            self.imageView2 = imageView;
        }
        imageView.frame = CGRectMake(padding + (imageViewHW + padding) * i, imageViewY, imageViewHW, imageViewHW);
        imageView.tag = i;
        imageView.image = [UIImage imageNamed:@"addImage"];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDidClick:)];
        [imageView addGestureRecognizer:tap];
        
        UILabel * pictureTitleLabel = [[UILabel alloc]init];
        pictureTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(24)];
        pictureTitleLabel.textColor = DRGrayTextColor;
        pictureTitleLabel.text = pictureTitles[i];
        CGSize titleLabelSize = [pictureTitleLabel.text sizeWithLabelFont:pictureTitleLabel.font];
        pictureTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(imageView.frame) + 5, titleLabelSize.width, 25);
        pictureTitleLabel.centerX = imageView.centerX;
        [contentView addSubview:pictureTitleLabel];
    }
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"*实名信息不允许修改，请认真填写";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(contentView.frame), screenWidth - DRMargin * 2, promptSize.height + 2 * 10);
    [scrollView addSubview:promptLabel];
    
    //店铺类型
    UIView * typeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(promptLabel.frame), screenWidth, 80)];
    self.typeView = typeView;
    typeView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:typeView];
    
    UILabel * typeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 10, screenWidth - 2 * DRMargin, 30)];
    typeTitleLabel.text = @"店铺类型选择";
    typeTitleLabel.textColor = DRBlackTextColor;
    typeTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [typeView addSubview:typeTitleLabel];
    
    NSArray * typeTexts = @[@"基地大棚", @"玩家", @"代理商"];
    for (int i = 0; i < typeTexts.count; i++) {
        UIButton * typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        typeButton.tag = i;
        typeButton.frame = CGRectMake(110 * i, 40, 110, 30);
        [typeButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
        [typeButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
        [typeButton setTitle:typeTexts[i] forState:UIControlStateNormal];
        [typeButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        typeButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        [typeButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
        if (i == 0) {
            self.typeSelectedButton = typeButton;
            typeButton.selected = YES;
        }
        [typeButton addTarget:self action:@selector(typeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [typeView addSubview:typeButton];
    }
    
    //基地
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(typeView.frame), screenWidth, 200)];
    self.baseView = baseView;
    baseView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:baseView];
    
    UIView * baseLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    baseLine.backgroundColor = DRWhiteLineColor;
    [baseView addSubview:baseLine];
    
    //图片
    DRAddMultipleImageView * addImageView = [[DRAddMultipleImageView alloc] initWithFrame:CGRectMake(0, 1, screenWidth, 0)];
    self.addImageView = addImageView;
    addImageView.titleLabel.text = @"请提供至少三张基地大棚实拍图";
    addImageView.maxImageCount = 3;
    addImageView.height = [addImageView getViewHeight];
    addImageView.delegate = self;
    [baseView addSubview:addImageView];
    
    //视频
    UILabel * videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(addImageView.frame), screenWidth - 2 * DRMargin, 35)];
    videoTitleLabel.textColor = DRBlackTextColor;
    videoTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    videoTitleLabel.text = @"请提供至少1个长于15s的基地大棚实拍视频";
    [baseView addSubview:videoTitleLabel];
    
    //基地大棚地址
    UIView * addressView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(videoTitleLabel.frame), screenWidth, DRCellH)];
    [baseView addSubview:addressView];
    
    UILabel * addressLabel = [[UILabel alloc] init];
    addressLabel.text = @"基地大棚地址";
    addressLabel.textColor = DRBlackTextColor;
    addressLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize addressLabelSize = [addressLabel.text sizeWithLabelFont:addressLabel.font];
    addressLabel.frame = CGRectMake(DRMargin, 0, addressLabelSize.width, DRCellH);
    [addressView addSubview:addressLabel];
    
    UITextField * addressTF = [[UITextField alloc] init];
    self.addressTF = addressTF;
    CGFloat addressTFX = CGRectGetMaxX(addressLabel.frame) + DRMargin;
    addressTF.frame = CGRectMake(addressTFX, 0, screenWidth - addressTFX - DRMargin, DRCellH);
    addressTF.textColor = DRBlackTextColor;
    addressTF.textAlignment = NSTextAlignmentRight;
    addressTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    addressTF.tintColor = DRDefaultColor;
    addressTF.keyboardType = UIKeyboardTypeNumberPad;
    addressTF.placeholder = @"请具体到街道及门牌号等";
    [addressView addSubview:addressTF];
   
    baseView.height = CGRectGetMaxY(addressView.frame);
    //协议
    UIView *agreementView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(baseView.frame), screenWidth, 60)];
    self.agreementView = agreementView;
    [scrollView addSubview:agreementView];
    
    UILabel *agreementLabel = [[UILabel alloc] init];
    agreementLabel.text = @"卖家须知";
    agreementLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    agreementLabel.textAlignment = NSTextAlignmentLeft;
    agreementLabel.textColor = DRGrayTextColor;
    CGSize agreementLabelSize = [agreementLabel.text sizeWithLabelFont:agreementLabel.font];
    agreementLabel.frame = CGRectMake(DRMargin, 10, agreementLabelSize.width, 20);
    [agreementView addSubview:agreementLabel];
    
    UIButton *agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn setTitle:@"查看" forState:UIControlStateNormal];
    [agreementBtn setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    agreementBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize megBtnSize = [agreementBtn.currentTitle sizeWithLabelFont:agreementBtn.titleLabel.font];
    agreementBtn.frame = CGRectMake(CGRectGetMaxX(agreementLabel.frame) + 5, 10, megBtnSize.width, 20);
    [agreementBtn addTarget:self action:@selector(seeAgreement) forControlEvents:UIControlEventTouchUpInside];
    [agreementView addSubview:agreementBtn];
    
    UIButton *agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.agreementButton = agreementButton;
    agreementButton.frame = CGRectMake(0, 30, 240, 30);
    [agreementButton setTitle:@"我已仔细阅读并同意卖家须知" forState:UIControlStateNormal];
    [agreementButton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    agreementButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    [agreementButton setImage:[UIImage imageNamed:@"shoppingcar_not_selected"] forState:UIControlStateNormal];
    [agreementButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateSelected];
    [agreementButton setImage:[UIImage imageNamed:@"shoppingcar_selected"] forState:UIControlStateHighlighted];
    [agreementButton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    [agreementButton addTarget:self action:@selector(agreementButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [agreementView addSubview:agreementButton];
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(agreementView.frame));
}

#pragma mark - 按钮点击
- (void)imageViewDidClick:(UIGestureRecognizer *)ges
{
    [self.view endEditing:YES];
    
    self.addImageManage = [[DRAddImageManage alloc] init];
    self.addImageManage.viewController = self;
    self.addImageManage.delegate = self;
    self.addImageManage.type = 0;
    self.addImageManage.tag = ges.view.tag;
    [self.addImageManage addImage];
}

- (void)imageManageCropImage:(UIImage *)image
{
    if (self.addImageManage.tag == 0) {
        self.imageView1.image = image;
        self.haveImage1 = YES;
    }else
    {
        self.imageView2.image = image;
        self.haveImage2 = YES;
    }
}

- (void)typeButtonDidClick:(UIButton *)button
{
    if (self.typeSelectedButton == button) {
        return;
    }
    
    button.selected = YES;
    self.typeSelectedButton.selected = NO;
    self.typeSelectedButton = button;
    
    if (button.tag == 0) {
        self.baseView.hidden = NO;
        self.agreementView.y = CGRectGetMaxY(self.baseView.frame);
    }else if (button.tag == 1)
    {
        self.baseView.hidden = YES;
        self.agreementView.y = CGRectGetMaxY(self.typeView.frame);
    }
    self.scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(self.agreementView.frame));
}

- (void)seeAgreement
{
    
}

- (void)agreementButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
}

- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    
}

@end
