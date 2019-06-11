//
//  DRGiveVoucherView.m
//  dr
//
//  Created by 毛文豪 on 2018/9/25.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRGiveVoucherView.h"
#import "DRRedPacketViewController.h"
#import "DRGiveVoucherTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "DRDateTool.h"

@interface DRGiveVoucherView ()<UIGestureRecognizerDelegate, UITableViewDelegate,UITableViewDataSource, DRGiveVoucherTableViewCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic,weak) UIView *backView;
@property (nonatomic,weak) UIImageView *topImageView;
@property (nonatomic,weak) UIImageView * bgImageView;
@property (nonatomic, weak) UIButton * goButton;
@property (nonatomic, weak) UIImageView *closeImageView;
@property (nonatomic, strong) NSArray *redPacketList;

@end

@implementation DRGiveVoucherView

- (instancetype)initWithFrame:(CGRect)frame redPacketList:(NSArray *)redPacketList
{
    self = [super initWithFrame:frame];
    if (self) {
        self.redPacketList = redPacketList;
        [self setupChildViews];
    }
    return self;
}

- (void)setupChildViews
{
    //背景
    UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
    backView.backgroundColor = DRColor(0, 0, 0, 0.5);
    [self addSubview:backView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    tap.delegate = self;
    [backView addGestureRecognizer:tap];
    
    NSInteger count = self.redPacketList.count > 3 ? 3 : self.redPacketList.count;
    CGFloat topImageViewH = 131 * screenWidth / 320;
    CGFloat bgImageViewH = (70 + count * 85);
    CGFloat closeImageViewWH = scaleScreenWidth(37);
    //顶部图片
    CGFloat topImageViewY = (self.height - topImageViewH - bgImageViewH - 25 - closeImageViewWH) / 2;
    CGFloat topImageViewW = scaleScreenWidth(320);
    CGFloat topImageViewX = (self.width - topImageViewW) / 2;
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(topImageViewX, topImageViewY, topImageViewW, topImageViewH)];
    self.topImageView = topImageView;
    topImageView.image = [UIImage imageNamed:@"give_voucher_top"];
    [backView addSubview:topImageView];
    
    //背景图片
    CGFloat bgImageViewY = CGRectGetMaxY(topImageView.frame);
    CGFloat bgImageViewW = scaleScreenWidth(320);
    CGFloat bgImageViewX = (self.width - bgImageViewW) / 2;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bgImageViewX, bgImageViewY, bgImageViewW, bgImageViewH)];
    self.bgImageView = bgImageView;
    UIImage * bgImage = [[UIImage imageNamed:@"give_voucher_bg"] stretchableImageWithLeftCapWidth:bgImageViewW / 2 topCapHeight:bgImageViewH / 2];
    bgImageView.image = bgImage;
    bgImageView.userInteractionEnabled = YES;
    [backView addSubview:bgImageView];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, bgImageView.width, count * 85)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor clearColor];
    [bgImageView addSubview:tableView];
    
    //查看我的彩券
    UIButton * goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.goButton = goButton;
    [goButton setTitle:@"查看我的红包" forState:UIControlStateNormal];
    [goButton setTitleColor:UIColorFromRGB(0xffcb30) forState:UIControlStateNormal];
    goButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    CGSize goButtonSize = [goButton.currentTitle sizeWithLabelFont:goButton.titleLabel.font];
    goButton.frame = CGRectMake((bgImageView.width - goButtonSize.width) / 2, bgImageView.height - 40, goButtonSize.width, goButtonSize.height);
    [goButton addTarget:self action:@selector(gotoVoucher) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:goButton];
    
    //关闭图片
    CGFloat closeImageViewY = CGRectGetMaxY(bgImageView.frame) + 25;
    CGFloat closeImageViewX = (self.width - closeImageViewWH) / 2;
    
    UIImageView *closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(closeImageViewX, closeImageViewY, closeImageViewWH, closeImageViewWH)];
    self.closeImageView = closeImageView;
    closeImageView.image = [UIImage imageNamed:@"give_voucher_close"];
    [backView addSubview:closeImageView];
    
    UITapGestureRecognizer * closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeImageViewDidClick)];
    closeImageView.userInteractionEnabled = YES;
    [closeImageView addGestureRecognizer:closeTap];
}

- (void)closeImageViewDidClick
{
    [self removeFromSuperview];
}

- (void)gotoVoucher
{
    DRRedPacketViewController * redPacketVC = [[DRRedPacketViewController alloc] init];
    [self.owerViewController pushViewController:redPacketVC animated:YES];
    
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint topPos = [touch locationInView:self.topImageView.superview];
        CGPoint bgPos = [touch locationInView:self.bgImageView.superview];
        if (CGRectContainsPoint(self.topImageView.frame, topPos) || CGRectContainsPoint(self.bgImageView.frame, bgPos)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.redPacketList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRGiveVoucherTableViewCell * cell = [DRGiveVoucherTableViewCell cellWithTableView:tableView];
    cell.coupon = self.redPacketList[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (void)giveVoucherTableViewCell:(DRGiveVoucherTableViewCell *)cell giveButtonDidClick:(UIButton *)button
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    Coupon * coupon = self.redPacketList[indexPath.row];
    coupon.status = @"1";
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)useVoucher
{
    [self goHome];
    [self removeFromSuperview];
}

- (void)goHome
{
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.owerViewController popToRootViewControllerAnimated:NO];
        });
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoHomePage" object:nil];
        });
    }];
    [op2 addDependency:op1];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue waitUntilAllOperationsAreFinished];
    [queue addOperation:op1];
    [queue addOperation:op2];
}

@end
