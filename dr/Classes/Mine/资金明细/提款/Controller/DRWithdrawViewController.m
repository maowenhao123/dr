//
//  DRWithdrawViewController.m
//  dr
//
//  Created by apple on 17/1/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRWithdrawViewController.h"
#import "DRAddBankCardViewController.h"
#import "DRSetFunPasswordViewController.h"
#import "DRDecimalTextField.h"
#import "DRWithdrawalBankCardTableViewCell.h"
#import "DRSetFunPasswordViewController.h"

@interface DRWithdrawViewController ()<UITableViewDelegate,UITableViewDataSource,AddBankCardDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UILabel * balanceLabel;
@property (nonatomic, weak) DRDecimalTextField *withdrawalTF;
@property (nonatomic, weak) UIButton * submitBtn;
@property (nonatomic, strong) NSArray *bankCards;
@property (nonatomic, assign) NSInteger selBankCardIndex;

@end

@implementation DRWithdrawViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!UserId)
    {
        [MBProgressHUD hideHUDForView:self.view];
        return;
    }
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"B01",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            DRMyShopModel *shopModel = [DRMyShopModel mj_objectWithKeyValues:json];
            [DRUserDefaultTool saveMyShopModel:shopModel];
            self.balanceLabel.text = [NSString stringWithFormat:@"%@元", [DRTool formatFloat:[shopModel.balance doubleValue] / 100]];
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提款";
    [self setupChilds];
    [self getData];
}
#pragma mark - 请求数据
- (void)getData
{
    NSDictionary *bodyDic = @{
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U12",
                              @"userId":UserId,
                              };
    waitingView
    [[DRHttpTool shareInstance] postWithTarget:self headDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.bankCards = [DRBankCardModel mj_objectArrayWithKeyValuesArray:json[@"list"]];
            for (int i = 0; i < self.bankCards.count; i++) {
                DRBankCardModel * model = self.bankCards[i];
                if (i == 0) {//默认第一个被选中
                    model.isSelected = YES;
                    self.selBankCardIndex = 0;
                }else
                {
                    model.isSelected = NO;
                }
            }
            [self.tableView reloadData];
            [self setTableFooterView];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        DRLog(@"error:%@",error);
    }];
}
- (void)withDrawalWithPassWord:(NSString *)passWord
{
    NSNumber * money = [NSNumber numberWithInt:[DRTool getHighPrecisionDouble:[self.withdrawalTF.text doubleValue]]];
    DRBankCardModel * bankCardModel = self.bankCards[self.selBankCardIndex];
    NSDictionary *bodyDic = @{
                              @"money":money,
                              @"name":bankCardModel.name,
                              @"bankName":bankCardModel.bankName,
                              @"cardNo":bankCardModel.cardNo,
                              @"fundPassword":passWord
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"U21",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            [MBProgressHUD showSuccess:@"提款成功"];
            [self.navigationController popViewControllerAnimated:YES];
            //更新数据发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"withdrawSuccess" object:nil];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
#pragma mark - 布局视图
- (void)setupChilds
{
    //主TableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    //headerView
    UIView *headerView = [[UIView alloc]init];
    
    //余额
    UIView * balanceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, DRCellH)];
    balanceView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:balanceView];
    
    UILabel * balancePromptLabel = [[UILabel alloc]init];
    balancePromptLabel.text = @"可提款";
    balancePromptLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    balancePromptLabel.textColor = DRBlackTextColor;
    CGSize balancePrompSize = [balancePromptLabel.text sizeWithLabelFont:balancePromptLabel.font];
    balancePromptLabel.frame = CGRectMake(DRMargin, 0, balancePrompSize.width, balanceView.height);
    [balanceView addSubview:balancePromptLabel];
    
    UILabel * balanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth - 80 - DRMargin, 0, 80, balanceView.height)];
    self.balanceLabel = balanceLabel;
    balanceLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    balanceLabel.textColor = DRDefaultColor;
    balanceLabel.textAlignment = NSTextAlignmentRight;
    [balanceView addSubview:balanceLabel];
    
    //提款输入框
    UIView * withdrawalView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(balanceView.frame) + 9, screenWidth, DRCellH)];
    withdrawalView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:withdrawalView];
    
    UILabel * withdrawalLabel = [[UILabel alloc]init];
    withdrawalLabel.text = @"提款金额(元)";
    withdrawalLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    withdrawalLabel.textColor = DRBlackTextColor;
    CGSize withdrawalSize = [withdrawalLabel.text sizeWithLabelFont:withdrawalLabel.font];
    withdrawalLabel.frame = CGRectMake(DRMargin, 0, withdrawalSize.width, withdrawalView.height);
    [withdrawalView addSubview:withdrawalLabel];
    
    DRDecimalTextField *withdrawalTF = [[DRDecimalTextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(withdrawalLabel.frame) + DRMargin, 0, screenWidth - CGRectGetMaxX(withdrawalLabel.frame) - 2 * DRMargin, DRCellH)];
    self.withdrawalTF = withdrawalTF;
    withdrawalTF.textAlignment = NSTextAlignmentRight;
    withdrawalTF.keyboardType = UIKeyboardTypeDecimalPad;
    withdrawalTF.borderStyle = UITextBorderStyleNone;
    withdrawalTF.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    withdrawalTF.textColor = DRBlackTextColor;
    withdrawalTF.tintColor = DRDefaultColor;
    withdrawalTF.placeholder = @"请输入提款金额";
    [withdrawalView addSubview:withdrawalTF];
    
    headerView.frame = CGRectMake(0, 0, screenHeight, CGRectGetMaxY(withdrawalView.frame) + 9);
    tableView.tableHeaderView = headerView;
    
    [self setTableFooterView];
}
- (void)setTableFooterView
{
    if (self.bankCards.count == 0) {//没有银行卡时
        //footerView
        UIView * footerView = [[UIView alloc]init];
        
        //提示
        UILabel * promptLabel = [[UILabel alloc]init];
        promptLabel.text = @"您还未绑定银行卡，请绑定！";
        promptLabel.textColor = DRGrayTextColor;
        promptLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
        CGSize promptLabelSize = [promptLabel.text sizeWithLabelFont:promptLabel.font];
        promptLabel.frame = CGRectMake(15, 9, screenWidth - 2 * DRMargin, promptLabelSize.height);
        [footerView addSubview:promptLabel];
        
        //添加银行卡
        UIButton * addBankCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBankCardBtn.frame = CGRectMake(15, CGRectGetMaxY(promptLabel.frame) + 20, screenWidth - 15 * 2, 40);
        addBankCardBtn.backgroundColor = DRDefaultColor;
        [addBankCardBtn setTitle:@"绑定银行卡" forState:UIControlStateNormal];
        [addBankCardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addBankCardBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        [addBankCardBtn addTarget:self action:@selector(addBankCardBtnClick) forControlEvents:UIControlEventTouchUpInside];
        addBankCardBtn.layer.cornerRadius = addBankCardBtn.height / 2;
        [footerView addSubview:addBankCardBtn];
        
        footerView.frame = CGRectMake(0, 0, screenWidth, CGRectGetMaxY(addBankCardBtn.frame) + 10);
        self.tableView.tableFooterView = footerView;
    }else
    {
        //footerView
        UIView * footerView = [[UIView alloc]init];
        
        //添加银行卡
        UIButton * addBankCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBankCardBtn.backgroundColor = [UIColor clearColor];
        [addBankCardBtn setTitle:@"+添加银行卡" forState:UIControlStateNormal];
        [addBankCardBtn setTitleColor:DRGrayTextColor forState:UIControlStateNormal];
        addBankCardBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        CGSize addBankCardBtnSize = [addBankCardBtn.currentTitle sizeWithLabelFont:addBankCardBtn.titleLabel.font];
        addBankCardBtn.frame = CGRectMake(15, 0, addBankCardBtnSize.width, 40);
        [addBankCardBtn addTarget:self action:@selector(addBankCardBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:addBankCardBtn];
        
        //提交
        UIButton * submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.submitBtn = submitBtn;
        submitBtn.frame = CGRectMake(15 ,CGRectGetMaxY(addBankCardBtn.frame) + 10, screenWidth - 2 * 15, 40);
        submitBtn.backgroundColor = DRDefaultColor;
        [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        submitBtn.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
        submitBtn.layer.cornerRadius = submitBtn.height / 2;
        [submitBtn addTarget:self action:@selector(withdrawButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:submitBtn];
        
        footerView.frame = CGRectMake(0, 0, screenWidth, CGRectGetMaxY(submitBtn.frame) + 10);
        self.tableView.tableFooterView = footerView;
    }
}
//添加银行卡
- (void)addBankCardBtnClick
{
    DRAddBankCardViewController * addBankCardVC = [[DRAddBankCardViewController alloc]init];
    addBankCardVC.delegate = self;
    [self.navigationController pushViewController:addBankCardVC animated:YES];
}
//添加银行卡成功
- (void)addBankSuccess
{
    [self getData];
}
- (void)withdrawButtonDidClick
{
    DRUser *user = [DRUserDefaultTool user];
    if (!user.hasFundPassword) {//没有设置提款密码
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您还未设置提款密码，请先设置提款密码再提款。" preferredStyle:UIAlertControllerStyleAlert];
        // 创建操作
        UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            DRSetFunPasswordViewController * setFunPwdVC = [[DRSetFunPasswordViewController alloc] init];
            [self.navigationController pushViewController:setFunPwdVC animated:YES];
        }];
        UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:alertAction1];
        [alertController addAction:alertAction2];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    double totalBalance = [self.balanceLabel.text doubleValue];
    double withDrawalMoney = [self.withdrawalTF.text doubleValue];
    if (totalBalance == 0) {
        [MBProgressHUD showError:@"可提款金额为0"];
        return;
    }
    if (withDrawalMoney == 0) {
        [MBProgressHUD showError:@"请输入提款金额"];
        return;
    }
    if (totalBalance < withDrawalMoney) {
        [MBProgressHUD showError:@"可提款金额不足"];
        return;
    }
    //输入提款密码
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"为了您的账户资金安全" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"请输入提款密码";
        textField.secureTextEntry = YES;
    }];
    // 创建操作
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *passWordTF = alertController.textFields.firstObject;
        [passWordTF resignFirstResponder];
        [self withDrawalWithPassWord:passWordTF.text];
    }];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bankCards.count == 0 ? 0 : self.bankCards.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *rid = @"withrawalAccountCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:rid];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      reuseIdentifier:rid];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.x = DRMargin;
        cell.textLabel.text = @"提款账号";
        cell.textLabel.textColor = DRGrayTextColor;
        cell.textLabel.font = [UIFont systemFontOfSize:DRGetFontSize(22)];
        return cell;
    }else
    {
        DRWithdrawalBankCardTableViewCell * cell = [[DRWithdrawalBankCardTableViewCell alloc]init];
        cell.bankCardModel = self.bankCards[indexPath.row - 1];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 28;
    }
    return DRCellH;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return;
    
    //关闭已选中的cell
    if (self.selBankCardIndex == indexPath.row - 1) {//当前是选中状态的
        return;
    }
    NSMutableArray * indexPaths = [NSMutableArray array];
    for (int i = 0; i < self.bankCards.count; i++) {
        DRBankCardModel * bankCardModel = self.bankCards[i];
        if (bankCardModel.isSelected) {
            bankCardModel.isSelected = NO;
            NSIndexPath * openIndexPath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
            [indexPaths addObject:openIndexPath];
        }
    }
    //点击的indexPath
    DRBankCardModel * bankCardModel = self.bankCards[indexPath.row - 1];
    bankCardModel.isSelected = YES;//选中
    [indexPaths addObject:indexPath];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    self.selBankCardIndex = indexPath.row - 1;
}
#pragma mark - 初始化
- (NSArray *)bankCards
{
    if (_bankCards == nil) {
        _bankCards = [NSArray array];
    }
    return _bankCards;
}
@end
