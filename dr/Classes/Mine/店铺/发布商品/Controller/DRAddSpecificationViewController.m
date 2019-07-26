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
    
    if (self.goodSpecificationModel) {
        self.nameTF.text = self.goodSpecificationModel.name;
        self.priceTF.text = self.goodSpecificationModel.price;
        self.countTF.text = self.goodSpecificationModel.plusCount;
        self.nameTF.text = self.goodSpecificationModel.name;
        [self.addImageView setImagesWithImage:@[self.goodSpecificationModel.pic]];
    }
}

#pragma mark - 点击确定按钮
- (void)confirmBtnDidClick
{
    DRGoodSpecificationModel *specificationModel = [[DRGoodSpecificationModel alloc] init];
    specificationModel.name = self.nameTF.text;
    specificationModel.price = self.priceTF.text;
    specificationModel.plusCount = self.countTF.text;
    specificationModel.pic = self.addImageView.images.firstObject;
    if (self.goodSpecificationModel) {
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
