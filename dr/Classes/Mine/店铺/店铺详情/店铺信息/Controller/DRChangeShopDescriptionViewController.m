//
//  DRChangeShopDescriptionViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeShopDescriptionViewController.h"
#import "DRTextView.h"

@interface DRChangeShopDescriptionViewController ()

@property (nonatomic, weak) DRTextView *shopDescriptionTV;//店铺简介输入

@end

@implementation DRChangeShopDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改店铺简介";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    DRTextView *shopDescriptionTV = [[DRTextView alloc] initWithFrame:CGRectMake(5, 9, screenWidth - 2 * 5, 100)];
    self.shopDescriptionTV = shopDescriptionTV;
    shopDescriptionTV.backgroundColor = [UIColor whiteColor];
    shopDescriptionTV.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    shopDescriptionTV.textColor = DRBlackTextColor;
    DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
    shopDescriptionTV.text = myShopModel.description_;
    shopDescriptionTV.myPlaceholder = @"用100个字介绍一下您的店铺吧";
    shopDescriptionTV.maxLimitNums = 100;
    shopDescriptionTV.tintColor = DRDefaultColor;
    [self.view addSubview:shopDescriptionTV];
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.shopDescriptionTV.text))
    {
        [MBProgressHUD showError:@"您还未输入店铺简介"];
        return;
    }
    
    if ([DRTool stringContainsEmoji:self.shopDescriptionTV.text]) {
        [MBProgressHUD showError:@"请删掉特殊符号或表情后，再提交哦~"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"description":self.shopDescriptionTV.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U51",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRMyShopModel * myShopModel = [DRUserDefaultTool myShopModel];
            myShopModel.description_ = self.shopDescriptionTV.text;
            [DRUserDefaultTool saveMyShopModel:myShopModel];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataMyShopDescription" object:nil];
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
