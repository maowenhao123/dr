//
//  DRAddSpecificationViewController.m
//  dr
//
//  Created by dahe on 2019/7/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRAddSpecificationViewController.h"
#import "DRGoodSpecificationModel.h"
#import "DRDecimalTextField.h"
#import "DRAddMultipleImageView.h"

@interface DRAddSpecificationViewController ()

@property (nonatomic, weak) UITextField * nameTF;
@property (nonatomic, weak) DRDecimalTextField * priceTF;
@property (nonatomic, weak) UITextField * countTF;
@property (nonatomic, weak) DRAddMultipleImageView * addImageView;

@end

@implementation DRAddSpecificationViewController

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
    self.title = @"添加规格";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    NSArray * titles = @[@"规格名称", @"价格", @"库存"];
    for (int i = 0; i < 3; i++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 9 + DRCellH * i, screenWidth, DRCellH)];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin, 0, titleLabelSize.width, DRCellH);
        [view addSubview:titleLabel];
        
        UITextField * textField;
        if (i == 0) {
            textField = [[UITextField alloc] init];
            textField.placeholder = @"例如单头7cm大小";
            self.nameTF = textField;
        }else if (i == 1)
        {
            textField = [[DRDecimalTextField alloc] init];
            textField.placeholder = @"单位（元）";
            self.priceTF = (DRDecimalTextField *)textField;
        }else if (i == 2)
        {
            textField = [[UITextField alloc] init];
            textField.placeholder = @"请输入";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            self.countTF = textField;
        }
        CGFloat textFieldX = CGRectGetMaxX(titleLabel.frame) + DRMargin;
        textField.frame = CGRectMake(textFieldX, 0, screenWidth - textFieldX - DRMargin, DRCellH);
        textField.textColor = DRBlackTextColor;
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        [view addSubview:textField];
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, DRCellH - 1, screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [view addSubview:line];
    }
    
    //添加图片
    DRAddMultipleImageView * addImageView = [[DRAddMultipleImageView alloc] initWithFrame:CGRectMake(0, 9 + DRCellH * titles.count + 9, screenWidth, 0)];
    self.addImageView = addImageView;
    addImageView.height = [addImageView getViewHeight];
    addImageView.maxImageCount = 1;
    addImageView.supportVideo = NO;
    addImageView.titleLabel.text = @"商品图片";
    [self.view addSubview:addImageView];

    //确定按钮
    UIButton * confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(DRMargin, CGRectGetMaxY(addImageView.frame) + 29, screenWidth - 2 * DRMargin, 40);
    confirmBtn.backgroundColor = DRDefaultColor;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmBtn addTarget:self action:@selector(confirmBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = confirmBtn.height / 2;
    [self.view addSubview:confirmBtn];
    
    //温馨提示
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.numberOfLines = 0;
    NSString * promptStr = @"注意：本商品所有图片请在“商品图片”部分上传，规格图片仅为方便买家挑选规格。";
    NSMutableAttributedString * promptAttStr = [[NSMutableAttributedString alloc]initWithString:promptStr];
    [promptAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(0, promptAttStr.length)];
    [promptAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, promptAttStr.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [promptAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, promptAttStr.length)];
    promptLabel.attributedText = promptAttStr;
    CGSize promptSize = [promptLabel.attributedText boundingRectWithSize:CGSizeMake(screenWidth - DRMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    promptLabel.frame = CGRectMake(DRMargin, CGRectGetMaxY(confirmBtn.frame) + 10, screenWidth - DRMargin * 2, promptSize.height);
    [self.view addSubview:promptLabel];
    
    if (self.goodSpecificationModel) {
        self.nameTF.text = self.goodSpecificationModel.name;
        self.priceTF.text = self.goodSpecificationModel.price;
        self.countTF.text = self.goodSpecificationModel.storeCount;
        self.nameTF.text = self.goodSpecificationModel.name;
        if (self.goodSpecificationModel.pic) {
            [self.addImageView setImagesWithImage:@[self.goodSpecificationModel.pic]];
        } else
        {
            NSString * imageUrlStr = @"";
            if ([self.goodSpecificationModel.picUrl containsString:@"http"]) {
                imageUrlStr = self.goodSpecificationModel.picUrl;
            }else
            {
                imageUrlStr = [NSString stringWithFormat:@"%@%@%@", baseUrl, self.goodSpecificationModel.picUrl, smallPicUrl];
            }
            [self.addImageView setImagesWithImage:@[imageUrlStr]];
        }
    }
}

#pragma mark - 点击确定按钮
- (void)confirmBtnDidClick
{
    [self.view endEditing:YES];
    
    //判空
    if (DRStringIsEmpty(self.nameTF.text)) {
        [MBProgressHUD showError:@"未输入规格名称"];
        return;
    }
    
    if ([DRTool stringContainsEmoji:self.nameTF.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    if (DRStringIsEmpty(self.priceTF.text)) {
        [MBProgressHUD showError:@"未输入规格价格"];
        return;
    }
    
    if ([self.priceTF.text intValue] == 0) {
        [MBProgressHUD showError:@"价格不可为0"];
        return;
    }
    
    if (DRStringIsEmpty(self.countTF.text)) {
        [MBProgressHUD showError:@"未输入规格库存"];
        return;
    }
    
    if ([self.countTF.text intValue] == 0) {
        [MBProgressHUD showError:@"库存数不可为0"];
        return;
    }
    
    if (DRArrayIsEmpty(self.addImageView.images)) {
        [MBProgressHUD showError:@"请上传图片"];
        return;
    }
    
    DRGoodSpecificationModel *specificationModel = [[DRGoodSpecificationModel alloc] init];
    specificationModel.name = self.nameTF.text;
    specificationModel.price = self.priceTF.text;
    specificationModel.storeCount = self.countTF.text;
    if ([self.addImageView.images.firstObject isKindOfClass:[UIImage class]]) {
        specificationModel.pic = self.addImageView.images.firstObject;
    }else
    {
        specificationModel.picUrl = self.addImageView.images.firstObject;
    }
    if (self.goodSpecificationModel) {
        specificationModel.index = self.goodSpecificationModel.index;
        specificationModel.id = self.goodSpecificationModel.id;
        specificationModel.delFlag = self.goodSpecificationModel.delFlag;
        if (_delegate && [_delegate respondsToSelector:@selector(editSpecificationWithSpecificationModel:)]) {
            [_delegate editSpecificationWithSpecificationModel:specificationModel];
        }
    }else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(addSpecificationWithSpecificationModel:)]) {
            [_delegate addSpecificationWithSpecificationModel:specificationModel];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
