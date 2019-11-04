//
//  DRAddSeckillGoodViewController.m
//  dr
//
//  Created by 毛文豪 on 2019/1/18.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRAddSeckillGoodViewController.h"
#import "DRChooseGoodViewController.h"
#import "DRDecimalTextField.h"

@interface DRAddSeckillGoodViewController ()<ChooseGoodViewControllerDelegate>

@property (nonatomic, weak) UITextField *nameTF;
@property (nonatomic, weak) UITextField *priceTF;
@property (nonatomic, weak) UITextField *countTF;
@property (nonatomic, strong) DRGoodModel *goodModel;

@end

@implementation DRAddSeckillGoodViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择商品";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    CGFloat maxY = 0;
    NSArray * titles = @[@"选择商品", @"商品价格", @"数量"];
    NSArray * placeholders = @[@"未选择", @"请输入", @"请输入"];
    for (int i = 0; i < titles.count; i++) {
        CGFloat bgViewY = 9;
        if (i > 0) {
            bgViewY = 9 + DRCellH + 9 + DRCellH * (i - 1);
        }
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, bgViewY, screenWidth, DRCellH)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        maxY = CGRectGetMaxY(bgView.frame);
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.text = titles[i];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize titleLabelSize = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin, 0, titleLabelSize.width, DRCellH);
        [bgView addSubview:titleLabel];
        
        UITextField * textField;
        if (i == 1) {
           textField = [[DRDecimalTextField alloc] init];
        }else
        {
           textField = [[UITextField alloc] init];
        }
        CGFloat textFieldX = CGRectGetMaxX(titleLabel.frame) + DRMargin;
        textField.frame = CGRectMake(textFieldX, 0, screenWidth - textFieldX - DRMargin - 7, DRCellH);
        textField.textColor = DRBlackTextColor;
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        textField.placeholder = placeholders[i];
        [bgView addSubview:textField];
        
        if (i == 0) {
            self.nameTF = textField;
            textField.userInteractionEnabled = NO;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame =  CGRectMake(textFieldX, 0, screenWidth - textFieldX, DRCellH);
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, button.width - DRMargin - 10, 0, 0)];
            [button setImage:[UIImage imageNamed:@"small_black_accessory_icon"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(chooseGoodBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:button];
        }else if (i == 1)
        {
            self.priceTF = textField;
            //分割线
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH - 1, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [bgView addSubview:line];
        }else if (i == 2)
        {
            self.countTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
    }
    
    //确定
    UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(15, maxY + 50, screenWidth - 30, 40);
    confirmButton.backgroundColor = DRDefaultColor;
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.layer.cornerRadius = confirmButton.height / 2;
    [self.view addSubview:confirmButton];
}

- (void)chooseGoodBtnDidClick
{
    DRChooseGoodViewController * ChooseGoodVC = [[DRChooseGoodViewController alloc] init];
    ChooseGoodVC.delegate = self;
    [self.navigationController pushViewController:ChooseGoodVC animated:YES];
}

- (void)ChooseGoodViewControllerChooseGoodModel:(DRGoodModel *)goodModel
{
    self.goodModel = goodModel;
    self.nameTF.text = goodModel.name;
}

- (void)confirmButtonDidClick
{
    [self.view endEditing:YES];
    
    if (DRObjectIsEmpty(self.goodModel))
    {
        [MBProgressHUD showError:@"请选择商品"];
        return;
    }
    
    if (DRStringIsEmpty(self.priceTF.text))
    {
        [MBProgressHUD showError:@"请输入商品价格"];
        return;
    }
    
    if (DRStringIsEmpty(self.countTF.text))
    {
        [MBProgressHUD showError:@"请输入商品数量"];
        return;
    }
    
    NSNumber * discountPrice = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.priceTF.text doubleValue]]];
    NSDictionary *bodyDic = @{
                              @"activityId": self.activityId,
                              @"goodsId": self.goodModel.id,
                              @"discountPrice": discountPrice,
                              @"activityStock": self.countTF.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"G15",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"添加成功"];
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(addSeckillGoodSuccess)]) {
                [self->_delegate addSeckillGoodSuccess];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
        //结束刷新
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}

@end
