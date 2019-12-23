//
//  DROrderListFooterView.m
//  dr
//
//  Created by 毛文豪 on 2018/3/6.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DROrderListFooterView.h"
#import "DRDateTool.h"

@interface DROrderListFooterView ()

@property (nonatomic,weak) UIView * footerView;
@property (nonatomic,weak) UILabel * orderDetailLabel;
@property (nonatomic,weak) UILabel * timeLabel;
@property (nonatomic,strong) NSMutableArray *buttons;

@end

@implementation DROrderListFooterView

+ (DROrderListFooterView *)headerFooterViewWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"OrderListFooterViewId";
    DROrderListFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if(headerView == nil)
    {
        headerView = [[DROrderListFooterView alloc] initWithReuseIdentifier:ID];
    }
    return headerView;
}
//初始化子控件
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier])
    {
        [self setupChildViews];
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self    selector:@selector(countDownNotification) name:@"OrderCountDownNotification" object:nil];
    }
    return self;
}

- (void)setupChildViews
{
    //footerView
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 35 + 40)];
    self.footerView = footerView;
    footerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:footerView];
    
    //分割线
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    line1.backgroundColor = DRWhiteLineColor;
    [footerView addSubview:line1];
    
    //商品价格
    UILabel * orderDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, 0, screenWidth - 2 * DRMargin, 35)];
    self.orderDetailLabel = orderDetailLabel;
    orderDetailLabel.textColor = DRBlackTextColor;
    orderDetailLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    orderDetailLabel.textAlignment = NSTextAlignmentRight;
    [footerView addSubview:orderDetailLabel];
    
    //分割线
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 35, screenWidth, 1)];
    line2.backgroundColor = DRWhiteLineColor;
    [footerView addSubview:line2];
    
    //倒计时
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DRMargin, CGRectGetMaxY(line2.frame), screenWidth - 2 * DRMargin, 40)];
    self.timeLabel = timeLabel;
    timeLabel.textColor = DRDefaultColor;
    timeLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    timeLabel.hidden = YES;
    [footerView addSubview:timeLabel];
    
    //按钮
    CGFloat buttonW = 79;
    CGFloat buttonH = 30;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
        button.frame = CGRectMake(screenWidth - (buttonW + DRMargin) * (i + 1), CGRectGetMaxY(line2.frame) + (40 - buttonH) / 2, buttonW, buttonH);
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.height / 2;
        button.layer.borderWidth = 1;
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.layer.borderColor = DRGrayTextColor.CGColor;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:button];
        
        [self.buttons addObject:button];
    }
}

- (void)buttonDidClick:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonDidClick:)]) {
        [self.delegate buttonDidClick:button];
    }
}

- (void)countDownNotification
{
    NSInteger status = [_orderModel.status integerValue];
    //支付倒计时 15分钟
    NSDateComponents * components = [DRDateTool getDeltaDateToTimestampg:_orderModel.createTime + 15 * 60 * 1000];
    if (components.minute == 0 && components.second == 0 && status == 0) {
        //更新数据发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"upDataOrderStatus" object:nil];
    }else if ((components.minute < 0 || components.second < 0) || status != 0) {
        self.timeLabel.hidden = YES;
    }else
    {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [NSString stringWithFormat:@"支付倒计时：%ld分%ld秒", components.minute, components.second];
    }
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    
    for (int i = 0; i < 3; i++) {
        UIButton * button = self.buttons[i];
        button.tag = index;
    }
}

- (void)setOrderModel:(DROrderModel *)orderModel
{
    _orderModel = orderModel;
    
    NSInteger status = [_orderModel.status integerValue];
    
    if (self.isGroup) {
        if (status == 5) {//显示底部按钮
            self.footerView.height = 35 + 40;
        }else
        {
            self.footerView.height = 35;
        }
    }else
    {
        if (status == 0 || status == 5 || status == 20 || status == 30 || status == -1) {//显示底部按钮
            self.footerView.height = 35 + 40;
        }else
        {
            self.footerView.height = 35;
        }
    }
    
    NSInteger goodCount = 0;
    for (DRStoreOrderModel * storeOrder in _orderModel.storeOrders) {
        for (DROrderItemDetailModel *orderItemDetailModel in storeOrder.detail) {
            goodCount += [orderItemDetailModel.purchaseCount integerValue];
        }
    }
    self.orderDetailLabel.text = [NSString stringWithFormat:@"共%ld件商品 实付款：￥%@", (long)goodCount, [DRTool formatFloat:[orderModel.amountPayable doubleValue] / 100]];
    
    NSArray * buttonTitles;
    if (self.isGroup) {
        if (status == 5)//待成团
        {
            buttonTitles = @[@"邀请好友拼团"];
        }
    }else
    {
        if (status == 0) {//待付款
            buttonTitles = @[@"去支付", @"取消订单"];
        }else if (status == 5)//待成团
        {
            buttonTitles = @[@"邀请好友拼团"];
        }else if (status == 20)//待收货
        {
            buttonTitles = @[@"确认收货",@"查看物流", @"退款"];
        }else if (status == 30)//已完成
        {
            int unCommentCount = [orderModel.unCommentCount intValue];
            if (unCommentCount > 0) { //有未评价的商品
                buttonTitles = @[@"去评价", @"查看物流", @"删除订单"];
            }else
            {
                buttonTitles = @[@"查看物流", @"删除订单"];
            }
        }else if (status == -1)//已取消
        {
            buttonTitles = @[@"删除订单"];
        }
    }
    
    CGFloat buttonW = 79;
    CGFloat buttonH = 30;
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton * button = self.buttons[i];
        button.hidden = YES;
        if (i < buttonTitles.count) {
            button.hidden = NO;
            [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
            
            if ([button.titleLabel.text isEqualToString:@"邀请好友拼团"]) {
                buttonW = 99;
            }else
            {
                buttonW = 79;
            }
            button.frame = CGRectMake(screenWidth - (buttonW + DRMargin) * (i + 1), 35 + (40 - buttonH) / 2, buttonW, buttonH);
            
            if ([button.titleLabel.text isEqualToString:@"去支付"] || [button.titleLabel.text isEqualToString:@"去评价"] || [button.titleLabel.text isEqualToString:@"邀请好友拼团"]) {
                [button setTitleColor:DRDefaultColor forState:UIControlStateNormal];
                button.layer.borderColor = DRDefaultColor.CGColor;
            }else
            {
                [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
                button.layer.borderColor = DRGrayTextColor.CGColor;
            }
            
        }
    }
}

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

@end
