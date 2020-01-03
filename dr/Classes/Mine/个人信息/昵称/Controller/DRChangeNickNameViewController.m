//
//  DRChangeNickNameViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRChangeNickNameViewController.h"
#import "DRValidateTool.h"

@interface DRChangeNickNameViewController ()

@property (nonatomic, weak) UITextField * nickNameTF;

@end

@implementation DRChangeNickNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"修改昵称";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarDidClick)];
    
    UIView * nickNameView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    nickNameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nickNameView];
    
    UITextField * nickNameTF = [[UITextField alloc] init];
    self.nickNameTF = nickNameTF;
    DRUser *user = [DRUserDefaultTool user];
    nickNameTF.text = user.nickName;
    nickNameTF.frame = CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, DRCellH);
    nickNameTF.tintColor = DRDefaultColor;
    nickNameTF.textColor = DRBlackTextColor;
    nickNameTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    nickNameTF.placeholder = @"请输入昵称";
    nickNameTF.clearButtonMode = UITextFieldViewModeAlways;
    [nickNameView addSubview:nickNameTF];
}
- (void)saveBarDidClick
{
    [self.view endEditing:YES];
    
    if (DRStringIsEmpty(self.nickNameTF.text))
    {
        [MBProgressHUD showError:@"请输入的昵称"];
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"nickName":self.nickNameTF.text
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            DRUser *user = [DRUserDefaultTool user];
            user.nickName = self.nickNameTF.text;
            [DRUserDefaultTool saveUser:user];
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataUserNickName" object:nil];
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
