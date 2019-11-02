//
//  DRReturnGoodViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRReturnGoodViewController.h"
#import "DRTextView.h"
#import "DRAddMultipleImageView.h"
#import "DRDecimalTextField.h"

@interface DRReturnGoodViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) UITextField * countTF;
@property (nonatomic, weak) UITextField * moneyTF;
@property (nonatomic, weak) DRTextView *detailTV;
@property (nonatomic,weak) DRAddMultipleImageView * addImageView;
@property (nonatomic, strong) NSMutableArray *uploadImageUrlArray;

@end

@implementation DRReturnGoodViewController

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
    self.title = @"退款";
    [self setupChilds];
}

- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmBarDidClick)];
    
    //contentView
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, 0)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    NSArray * labelTitles = @[@"退款数量", @"退款总额"];
    //红包抵扣率
    double couponRate = [self.commentGoodModel.couponPrice doubleValue] / [self.commentGoodModel.orderPriceCount doubleValue];
    double realRefund = [self.commentGoodModel.priceCount doubleValue] * (1 - couponRate);
    NSArray * placeholders = @[[NSString stringWithFormat:@"%@", self.commentGoodModel.purchaseCount], [NSString stringWithFormat:@"%@", [DRTool formatFloat:realRefund / 100]]];
    for (int i = 0; i < labelTitles.count; i++) {
        //选择退款原因
        UILabel * label = [[UILabel alloc] init];
        label.text = labelTitles[i];
        label.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        label.textColor = DRBlackTextColor;
        CGSize labelSize = [label.text sizeWithLabelFont:label.font];
        label.frame = CGRectMake(DRMargin, DRCellH * i, labelSize.width, DRCellH);
        [contentView addSubview:label];
        
        UITextField * textField;
        if (i == 0) {
            textField = [[UITextField alloc] init];
            self.countTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
        }else
        {
            textField = [[DRDecimalTextField alloc] init];
            self.moneyTF = (UITextField *)textField;
            textField.userInteractionEnabled = NO;
        }
        CGFloat textFieldX = CGRectGetMaxX(label.frame) + DRMargin;
        textField.frame = CGRectMake(textFieldX, DRCellH * i, screenWidth - textFieldX - DRMargin, DRCellH);
        textField.textColor = DRBlackTextColor;
        textField.textAlignment = NSTextAlignmentRight;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.tintColor = DRDefaultColor;
        textField.placeholder = placeholders[i];
        [contentView addSubview:textField];
       
        //分割线
        UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, (DRCellH - 1) * (i + 1), screenWidth, 1)];
        line.backgroundColor = DRWhiteLineColor;
        [contentView addSubview:line];
    }
    
    UILabel * detailLabel = [[UILabel alloc] init];
    detailLabel.text = @"退款说明";
    detailLabel.textColor = DRBlackTextColor;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize detailLabelSize = [detailLabel.text sizeWithLabelFont:detailLabel.font];
    detailLabel.frame = CGRectMake(DRMargin, 9 + 2 * DRCellH, detailLabelSize.width, detailLabelSize.height);
    [contentView addSubview:detailLabel];
    
    //退款描述
    DRTextView *detailTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(detailLabel.frame) + 1, screenWidth - 2 * 5, 100)];
    self.detailTV = detailTV;
    detailTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    detailTV.textColor = DRBlackTextColor;
    detailTV.tintColor = DRDefaultColor;
    detailTV.myPlaceholder = @"退款说明";
    detailTV.maxLimitNums = 100;
    [contentView addSubview:detailTV];
    
    contentView.height = CGRectGetMaxY(detailTV.frame);
    
    //添加图片
    DRAddMultipleImageView * addImageView = [[DRAddMultipleImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame) + 9, screenWidth, 0)];
    self.addImageView = addImageView;
    addImageView.height = [addImageView getViewHeight];
    addImageView.maxImageCount = 6;
    addImageView.titleLabel.text = @"退款截图";
    [self.view addSubview:addImageView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.countTF) {
        if ([self.countTF.text intValue] > [self.commentGoodModel.purchaseCount intValue]) {
            textField.text = [NSString stringWithFormat:@"%@", self.commentGoodModel.purchaseCount];
        }
        
        double countRate = [self.countTF.text doubleValue] / [self.commentGoodModel.purchaseCount doubleValue];
        double couponRate = [self.commentGoodModel.couponPrice doubleValue] / [self.commentGoodModel.orderPriceCount doubleValue];
        double couponPriceF = ([self.commentGoodModel.priceCount doubleValue]  / 100) * couponRate * countRate;
        double actualRefundF = ([self.commentGoodModel.priceCount doubleValue]  / 100) * (1 - couponRate) * countRate;
        NSString * actualRefund = [NSString stringWithFormat:@"¥%@", [DRTool formatFloat:actualRefundF]];
        NSString * couponPrice = [NSString stringWithFormat:@"(抵扣-%@)", [DRTool formatFloat:couponPriceF]];
        NSMutableAttributedString * moneyAttStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", actualRefund, couponPrice]];
        [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRBlackTextColor range:[moneyAttStr.string rangeOfString:actualRefund]];
        [moneyAttStr addAttribute:NSForegroundColorAttributeName value:DRRedTextColor range:[moneyAttStr.string rangeOfString:couponPrice]];
        self.moneyTF.attributedText = moneyAttStr;
    }
}

- (void)confirmBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.countTF.text))
    {
        [MBProgressHUD showError:@"您还输入退款数量"];
        return;
    }
    if (DRStringIsEmpty(self.moneyTF.text))
    {
        [MBProgressHUD showError:@"您还输入退款总额"];
        return;
    }
    if (DRStringIsEmpty(self.detailTV.text))
    {
        [MBProgressHUD showError:@"您还输入退款说明"];
        return;
    }

    if (self.addImageView.images.count > 0) {
        self.uploadImageUrlArray = [NSMutableArray array];
        [self uploadImageWithImage:self.addImageView.images[0]];
    }else
    {
        [self uploadData];
    }
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
            [self uploadData];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    } Failure:^(NSError *error) {
        [self.uploadImageUrlArray addObject:@""];
        if (self.uploadImageUrlArray.count == self.addImageView.images.count)
        {
            [self uploadData];
        }else
        {
            [self uploadImageWithImage:self.addImageView.images[self.uploadImageUrlArray.count]];
        }
    }  Progress:^(float percent) {
        
    }];
}

- (void)uploadData
{
    //红包抵扣率
    double couponRate = [self.commentGoodModel.couponPrice doubleValue] / [self.commentGoodModel.orderPriceCount doubleValue];
    int count = [self.countTF.text intValue];
    double price = ([self.commentGoodModel.price doubleValue]  / 100) * (1 - couponRate);
    NSString * actualRefund = [NSString stringWithFormat:@"%@", [DRTool formatFloat:count * price]];
    NSNumber * money = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[actualRefund doubleValue]]];
    NSDictionary *orderGoodsRefund = @{
                                       @"orderId":self.commentGoodModel.orderId,
                                       @"goodsId":self.commentGoodModel.goods.id,
                                       @"count":self.countTF.text,
                                       @"description":self.detailTV.text,
                                       @"priceCount":money,
                                       @"pictures":self.uploadImageUrlArray,
                                       };
    NSMutableDictionary *orderGoodsRefund_mu = [NSMutableDictionary dictionaryWithDictionary:orderGoodsRefund];
    if (!DRObjectIsEmpty(self.commentGoodModel.specification)) {
        [orderGoodsRefund_mu setObject:self.commentGoodModel.specification.id forKey:@"specificationId"];
    }
    
    NSDictionary *bodyDic = @{
                              @"orderGoodsRefund":orderGoodsRefund_mu,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"S24",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"申请退款成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"returnGoodSuccess" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
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
