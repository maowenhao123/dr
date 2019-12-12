//
//  DRChatOrderView.m
//  dr
//
//  Created by dahe on 2019/11/25.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRChatOrderView.h"
#import "DRChatOrderTableViewCell.h"

@interface DRChatOrderView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation DRChatOrderView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = DRBackgroundColor;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self setEstimatedSectionHeaderHeightAndFooterHeight];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    
    if (_dataArray.count == 0) {
        self.hidden = YES;
    }else
    {
        self.hidden = NO;
        CGFloat maxH = (screenHeight - statusBarH - navBarH) / 2;
        CGFloat viewH = dataArray.count * 100 + 30;
        if (dataArray.count > 1) {
            viewH = 100 + 30;
        }else if (viewH > maxH)
        {
            viewH = maxH;
        }
        self.height = viewH;
    }
    
    [self reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRChatOrderTableViewCell * cell = [DRChatOrderTableViewCell cellWithTableView:tableView];
    cell.orderModel = self.dataArray[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton * footerView = [UIButton buttonWithType:UIButtonTypeCustom];
    footerView.frame = CGRectMake(0, 0, screenWidth, 30);
    footerView.backgroundColor = DRWhiteLineColor;
    if (self.dataArray.count > 1) {
       [footerView setImage:[UIImage imageNamed:@"chat_order_down"] forState:UIControlStateNormal];
    }else
    {
       [footerView setImage:[UIImage imageNamed:@"chat_order_up"] forState:UIControlStateNormal];
    }
    [footerView addTarget:self action:@selector(openCloseDidTap:) forControlEvents:UIControlEventTouchUpInside];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (void)openCloseDidTap:(UIButton *)button
{
    if (self.dataArray.count > 1) {
        if (self.height == 100 + 30 || self.height == 30) {
            [UIView animateWithDuration:DRAnimateDuration animations:^{
                CGFloat maxH = (screenHeight - statusBarH - navBarH) / 2;
                CGFloat viewH = self.dataArray.count * 100 + 30;
                if (self.dataArray.count == 1) {
                    viewH = 100 + 30;
                }else if (viewH > maxH)
                {
                    viewH = maxH;
                }
                self.height = viewH;
            }completion:^(BOOL finished) {
                [button setImage:[UIImage imageNamed:@"chat_order_up"] forState:UIControlStateNormal];
            }];
        }else
        {
            [UIView animateWithDuration:DRAnimateDuration animations:^{
                self.height = 30;
            }completion:^(BOOL finished) {
                [button setImage:[UIImage imageNamed:@"chat_order_down"] forState:UIControlStateNormal];
            }];
        }
    }else
    {
        if (self.height == 100 + 30) {
            [UIView animateWithDuration:DRAnimateDuration animations:^{
                self.height = 30;
            }completion:^(BOOL finished) {
                [button setImage:[UIImage imageNamed:@"chat_order_down"] forState:UIControlStateNormal];
            }];
        }else
        {
            [UIView animateWithDuration:DRAnimateDuration animations:^{
                self.height = 130;
            }completion:^(BOOL finished) {
                [button setImage:[UIImage imageNamed:@"chat_order_up"] forState:UIControlStateNormal];
            }];
        }
    }
}

@end
