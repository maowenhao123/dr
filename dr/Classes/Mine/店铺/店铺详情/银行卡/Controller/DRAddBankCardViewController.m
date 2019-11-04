//
//  DRAddBankCardViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAddBankCardViewController.h"
#import "DRBottomPickerView.h"
#import "DRValidateTool.h"

@interface DRAddBankCardViewController ()
{
    NSInteger _index;
}
@property (nonatomic, weak) UITextField *bankNameTF;
@property (nonatomic, weak) UITextField *bankNumberCardTF;
@property (nonatomic, weak) UITextField *nameTF;
@property (nonatomic, weak) UIButton *confirmBtn;

@end

@implementation DRAddBankCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加银行卡";
    [self setupChilds];
}
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    NSArray * titles = @[@"开户银行",@"银行卡号",@"持卡人姓名"];
    NSArray * placeholders = @[@"选择",@"请输入银行卡号",@"请输入持卡人姓名"];
    UIView * contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH * titles.count)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    for (int i = 0; i < titles.count; i++) {
        CGFloat viewY = i * DRCellH;
        
        UILabel * titleLabel = [[UILabel alloc]init];
        titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        titleLabel.textColor = DRBlackTextColor;
        titleLabel.text = titles[i];
        CGSize size = [titleLabel.text sizeWithLabelFont:titleLabel.font];
        titleLabel.frame = CGRectMake(DRMargin, viewY, size.width, DRCellH);
        [contentView addSubview:titleLabel];
        
        //textField
        UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame),viewY, screenWidth - CGRectGetMaxX(titleLabel.frame) - DRMargin, DRCellH)];
        textField.borderStyle = UITextBorderStyleNone;
        textField.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        textField.textColor = DRBlackTextColor;
        textField.textAlignment = NSTextAlignmentRight;
        textField.placeholder = placeholders[i];
        textField.tintColor = DRDefaultColor;
        if (i == 0) {
            self.bankNameTF = textField;
            textField.userInteractionEnabled = NO;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = textField.frame;
            [btn addTarget:self action:@selector(selectPickerView) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btn];
        }else if (i == 1)
        {
            self.bankNumberCardTF = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }else if (i == 2)
        {
            self.nameTF = textField;
        }
        [contentView addSubview:textField];
        
        //分割线
        if (i != 0) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, DRCellH * i, screenWidth, 1)];
            line.backgroundColor = DRWhiteLineColor;
            [contentView addSubview:line];
        }
    }
}

- (void)selectPickerView
{
    [self.view endEditing:YES];//取消其他键盘
    NSArray * bankNames = @[@"中国建设银行",@"中国工商银行",@"中国农业银行",@"中国邮政储蓄银行",@"中国银行",@"交通银行",@"招商银行",@"中国光大银行",@"兴业银行",@"平安银行",@"中国民生银行",@"上海浦东发展银行",@"广东发展银行",@"华夏银行",@"中信银行"];
    //选择银行
    DRBottomPickerView * bankChooseView = [[DRBottomPickerView alloc]initWithArray:bankNames index:_index];
    __weak typeof(self) wself = self;
    bankChooseView.block = ^(NSInteger selectedIndex){
        _index = selectedIndex;
        wself.bankNameTF.text = [NSString stringWithFormat:@"%@",bankNames[selectedIndex]];
    };
    [bankChooseView show];
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.bankNameTF.text))
    {
        [MBProgressHUD showError:@"您还未选择银行卡"];
        return;
    }
    
    if (![DRValidateTool validateCardNumber:self.bankNumberCardTF.text])
    {
        [MBProgressHUD showError:@"您输入的银行卡号格式不对"];
        return;
    }
    
    if (DRStringIsEmpty(self.nameTF.text))
    {
        [MBProgressHUD showError:@"您还未输入持卡人姓名"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"bankName":self.bankNameTF.text,
                              @"cardNo":self.bankNumberCardTF.text,
                              @"name":self.nameTF.text,
                              @"defaultv":@(0)
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U11",
                              @"userId":UserId,
                              };
    
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"银行卡添加成功"];
            if (_delegate && [_delegate respondsToSelector:@selector(addBankSuccess)]) {
                [_delegate addBankSuccess];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

@end
