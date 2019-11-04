//
//  DRActivityDetailView.m
//  dr
//
//  Created by 毛文豪 on 2019/1/24.
//  Copyright © 2019 JG. All rights reserved.
//

#import "DRActivityDetailView.h"
#import "DRDateTool.h"

@interface DRActivityDetailView ()<UIGestureRecognizerDelegate>

@property (nonatomic,weak) UIView * backView;
@property (nonatomic, strong) DRShopActivityModel *activityModel;

@end

@implementation DRActivityDetailView

- (instancetype)initWithFrame:(CGRect)frame activityModel:(DRShopActivityModel *)activityModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.activityModel = activityModel;
        [self setupChildViews];
    }
    return self;
}


- (void)setupChildViews
{
    self.backgroundColor = DRColor(0, 0, 0, 0.4);
    
    //添加点击事件
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClick)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    //背景
    CGFloat backViewW = 300;
    UIView * backView = [[UIView alloc] init];
    self.backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.masksToBounds = YES;
    backView.layer.cornerRadius = 8;
    [self addSubview:backView];
    
    //活动信息
    NSArray * titles = @[@"活动主题：", @"活动时间：", @"活动规则："];
    UIView * lastView;
    for (int i = 0; i < titles.count + 1; i++) {
        UILabel * label = [[UILabel alloc] init];
        CGFloat padding = 15;
        if (i == 0) {
            padding = 30;
            label.text = [NSString stringWithFormat:@"%@%@", titles[i], self.activityModel.title];
        }else if (i == 1)
        {
            NSString *beginTime = [DRDateTool getTimeByTimestamp:self.activityModel.beginTime format:@"yyyy-MM-dd"];
            NSString *endTime = [DRDateTool getTimeByTimestamp:self.activityModel.endTime format:@"yyyy-MM-dd"];
            label.text = [NSString stringWithFormat:@"%@%@ - %@", titles[i], beginTime, endTime];
        }else if (i == 2)
        {
            label.text = titles[i];
        }else if (i == 3)
        {
            padding = 10;
            label.text = [self filterHTML:self.activityModel.rule];
        }
        label.textColor = DRBlackTextColor;
        label.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
        label.numberOfLines = 0;
        CGSize labelSize = [label.text sizeWithFont:label.font maxSize:CGSizeMake(backViewW - 2 * 10, MAXFLOAT)];
        label.frame = CGRectMake(10, CGRectGetMaxY(lastView.frame) + padding, labelSize.width, labelSize.height);
        [backView addSubview:label];
        
        lastView = label;
    }

    backView.frame = CGRectMake(0, 0, backViewW, CGRectGetMaxY(lastView.frame) + 30);
    backView.center = CGPointMake(self.centerX, self.centerY - 70);
    
    //取消按钮
    CGFloat cancelButtonWH = scaleScreenWidth(37);
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(backView.centerX - cancelButtonWH / 2, CGRectGetMaxY(backView.frame) + 50, cancelButtonWH, cancelButtonWH);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"give_voucher_close"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
}

- (void)tapDidClick
{
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint pos = [touch locationInView:self.backView.superview];
        if (CGRectContainsPoint(self.backView.frame, pos)) {
            return NO;
        }
    }
    return YES;
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    return html;
}

@end
