//
//  DRShowPhoneViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/23.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowPhoneViewController.h"
#import "DRChangePhoneViewController.h"

@interface DRShowPhoneViewController ()

@property (nonatomic, weak) UILabel * detailLabel;

@end

@implementation DRShowPhoneViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setPhone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"已绑定手机";
    [self setupChilds];
}

- (void)setupChilds
{
    //rightBarButtonItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(changeBarDidClick)];
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 9, screenWidth, DRCellH)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    //名字
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    nameLabel.textColor = DRBlackTextColor;
    nameLabel.text = @"已绑定手机号码";
    [backView addSubview:nameLabel];
    
    CGSize nameLabelSize = [nameLabel.text sizeWithLabelFont:nameLabel.font];
    nameLabel.frame = CGRectMake(DRMargin, 0, nameLabelSize.width, DRCellH);
    
    //Detail
    UILabel * detailLabel = [[UILabel alloc] init];
    self.detailLabel = detailLabel;
    detailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    detailLabel.textColor = DRGrayTextColor;
    [backView addSubview:detailLabel];
    [self setPhone];
}

- (void)setPhone
{
    DRUser *user = [DRUserDefaultTool user];
    NSString * phone = user.phone;
    phone = [phone stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"*****"];
    self.detailLabel.text = phone;
    CGSize detailLabelSize = [self.detailLabel.text sizeWithLabelFont:self.detailLabel.font];
    self.detailLabel.frame = CGRectMake(screenWidth - DRMargin - detailLabelSize.width, 0, detailLabelSize.width, DRCellH);
}

- (void)changeBarDidClick
{
    DRChangePhoneViewController * changePhoneVC = [[DRChangePhoneViewController alloc] init];
    [self.navigationController pushViewController: changePhoneVC animated:YES];
}

@end
