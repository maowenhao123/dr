//
//  DRAccountInfoViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/4/1.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRAccountInfoViewController.h"
#import "DRChangeNickNameViewController.h"
#import "DRShowPhoneViewController.h"
#import "DRChangePassWordViewController.h"
#import "DRManageAddressViewController.h"
#import "DRBankCardViewController.h"
#import "DRTextTableViewCell.h"
#import "DRAddImageManage.h"
#import "PGDatePickManager.h"
#import "DRBottomPickerView.h"

@interface DRAccountInfoViewController ()<UITableViewDelegate,UITableViewDataSource, AddImageManageDelegate, PGDatePickerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) DRAddImageManage * addImageManage;
@property (nonatomic, strong) NSArray *functionNames;

@end

@implementation DRAccountInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"账户管理";
    [self setupChilds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDataNickname) name:@"upDataUserNickName" object:nil];
}

- (void)setupChilds
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH) style:UITableViewStyleGrouped];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DRBackgroundColor;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}

#pragma mark - cell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.functionNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * functionNames = self.functionNames[section];
    return functionNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRTextTableViewCell * cell = [DRTextTableViewCell cellWithTableView:tableView];
    NSArray * functionNames = self.functionNames[indexPath.section];
    cell.functionName = functionNames[indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) {//头像
        cell.avatarImageView.hidden = NO;
    }else
    {
        cell.avatarImageView.hidden = YES;
    }
    
    DRUser *user = [DRUserDefaultTool user];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//头像
            cell.functionDetail = nil;
            [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@%@",baseUrl,user.headImg]] placeholderImage:[UIImage imageNamed:@"avatar_placeholder"]];
        }else if (indexPath.row == 1)//昵称
        {
            cell.functionDetail = user.nickName;
        }else if (indexPath.row == 2)//性别
        {
            NSArray * sexs = @[@"男",@"女"];
            if ([user.sex integerValue] > 0) {
                cell.functionDetail = sexs[[user.sex integerValue] - 1];
            }else
            {
                cell.functionDetail = nil;
            }
        }else if (indexPath.row == 3)//生日
        {
            cell.functionDetail = user.birthday;
        }
    }
    //分割线
    if (indexPath.row == 0) {
        cell.line.hidden = YES;
    }else
    {
        cell.line.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }
    return DRCellH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DRUser *user = [DRUserDefaultTool user];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.addImageManage = [[DRAddImageManage alloc] init];
            self.addImageManage.viewController = self;
            self.addImageManage.delegate = self;
            self.addImageManage.type = 1;
            [self.addImageManage addImage];
        }else if (indexPath.row == 1)//昵称
        {
            DRChangeNickNameViewController * nickNameVC = [[DRChangeNickNameViewController alloc] init];
            [self.navigationController pushViewController:nickNameVC animated:YES];
        }else if (indexPath.row == 2)//性别
        {
            NSArray * sexs = @[@"男",@"女"];
            //选择性别
            NSInteger sexIndex = [user.sex integerValue] - 1;
            sexIndex = sexIndex < 0 ? 0 : sexIndex;
            DRBottomPickerView * sexChooseView = [[DRBottomPickerView alloc] initWithArray:sexs index:sexIndex];
            sexChooseView.block = ^(NSInteger selectedIndex){
                [self setSexInt:selectedIndex + 1];
            };
            [sexChooseView show];
        }else if (indexPath.row == 3) {//生日
            PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
            PGDatePicker *datePicker = datePickManager.datePicker;
            datePicker.datePickerType = PGPickerViewType2;
            datePicker.datePickerMode = PGDatePickerModeDate;
            datePicker.delegate = self;
            [self presentViewController:datePickManager animated:false completion:nil];
        }
    }else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)//绑定手机
        {
            if (DRStringIsEmpty(user.phone)) {
                DRBindingPhoneViewController * bindingPhoneVC = [[DRBindingPhoneViewController alloc] init];
                [self.navigationController pushViewController: bindingPhoneVC animated:YES];
            }else
            {
                DRShowPhoneViewController * showPhoneVC = [[DRShowPhoneViewController alloc] init];
                [self.navigationController pushViewController:showPhoneVC animated:YES];
            }
        }else if (indexPath.row == 1)//账户安全
        {
            DRChangePassWordViewController * passWordVC = [[DRChangePassWordViewController alloc] init];
            [self.navigationController pushViewController: passWordVC animated:YES];
        }else if (indexPath.row == 2) {//地址管理
            DRManageAddressViewController * addressVC = [[DRManageAddressViewController alloc] init];
            [self.navigationController pushViewController: addressVC animated:YES];
        }
    }
}

#pragma mark - 修改头像
- (void)imageManageCropImage:(UIImage *)image
{
    NSString * image64 = [DRTool stringByimageBase64WithImage:image];
    NSDictionary *bodyDic = @{
                                @"headImg":image64,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //更新数据发送通知
            [self upDataUser];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

- (void)upDataUser
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U10",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            //储存
            DRUser *user = [DRUser mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveUser:user];
            //刷新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataUserAvatar" object:nil];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 修改昵称
- (void)upDataNickname
{
    //刷新
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 修改性别
- (void)setSexInt:(NSInteger)sexInt
{
    NSDictionary *bodyDic = @{
                              @"sex":[NSNumber numberWithInteger:sexInt]
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRUser *user = [DRUserDefaultTool user];
            user.sex = [NSNumber numberWithInteger:sexInt];
            [DRUserDefaultTool saveUser:user];
            //刷新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 修改生日
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents
{
    NSString *birthdayStr = [NSString stringWithFormat:@"%ld-%ld-%ld", dateComponents.year, dateComponents.month, dateComponents.day];
    [self setBirthdayStr:birthdayStr];
}

- (void)setBirthdayStr:(NSString *)birthdayStr
{
    NSDictionary *bodyDic = @{
                              @"birthday":birthdayStr
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U06",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRUser *user = [DRUserDefaultTool user];
            user.birthday = birthdayStr;
            [DRUserDefaultTool saveUser:user];
            //刷新
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化
- (NSArray *)functionNames
{
    if (!_functionNames) {
        _functionNames = @[@[@"头像",@"昵称",@"性别",@"生日"],
                           @[@"绑定手机",@"修改密码",@"地址管理"]
                           ];
    }
    return _functionNames;
}

@end
