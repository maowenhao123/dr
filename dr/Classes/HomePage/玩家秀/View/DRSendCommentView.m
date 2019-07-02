//
//  DRSendCommentView.m
//  dr
//
//  Created by 毛文豪 on 2017/7/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSendCommentView.h"
#import "DRLoginViewController.h"

@interface DRSendCommentView ()<UITextViewDelegate>

@end

@implementation DRSendCommentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
        [self setupChilds];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
        [self setupChilds];
    }
    return self;
}
- (void)setupChilds
{
    self.backgroundColor = [UIColor whiteColor];
    //阴影
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowOpacity = 0.5;
    
    //发送
    UIButton * sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton = sendButton;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    [sendButton setTitleColor:DRGrayTextColor forState:UIControlStateDisabled];
    sendButton.enabled = NO;//默认不可选
    sendButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    [sendButton addTarget:self action:@selector(sendButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    sendButton.frame = CGRectMake(self.width - 60, 0, 60, 40);
    [self addSubview:sendButton];
    
    //点赞
    UIButton * praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.praiseButton = praiseButton;
    praiseButton.frame = sendButton.frame;
    praiseButton.hidden = YES;
    [praiseButton setImage:[UIImage imageNamed:@"show_praise_gray"] forState:UIControlStateNormal];
    [praiseButton setImage:[UIImage imageNamed:@"show_praise_light"] forState:UIControlStateSelected];
    [praiseButton setTitleColor:DRDefaultColor forState:UIControlStateNormal];
    praiseButton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    praiseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [praiseButton addTarget:self action:@selector(praiseButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:praiseButton];
    
    DRTextView * textView = [[DRTextView alloc] init];
    self.textView = textView;
    textView.frame = CGRectMake(DRMargin, 5, sendButton.x - DRMargin, 30);
    textView.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    textView.tintColor = DRDefaultColor;
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES;
    textView.delegate = self;
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 5;
    textView.layer.borderColor = DRWhiteLineColor.CGColor;
    textView.layer.borderWidth = 1;
    [self addSubview:textView];
}

- (void)sendButtonDidClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewSendButtonDidClickWithText:)]) {
        [self.delegate textViewSendButtonDidClickWithText:self.textView.text];
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    self.sendButton.enabled = textView.text.length > 0;
    static CGFloat maxHeight = 100.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<=frame.size.height) {
        size.height=frame.size.height;
    }else{
        if (size.height >= maxHeight)
        {
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
        }
        else
        {
            textView.scrollEnabled = NO;    // 不允许滚动
        }
    }
    textView.height = size.height;
    self.sendButton.centerY = textView.centerY;
    self.height = size.height + 10;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewChangeHeight:)]) {
        [self.delegate textViewChangeHeight:self.frame.size.height];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        [self sendButtonDidClick];
        return NO;
    }
    
    return YES;
}
- (void)reset
{
    self.textView.height = 30;
    self.height = 40;
    self.sendButton.centerY = self.textView.centerY;
    self.textView.text = nil;
    self.sendButton.enabled = NO;
    self.artId = nil;
    self.toUserId = nil;
    self.indexPath = nil;
    self.index = 0;
    self.textView.myPlaceholder = nil;
}
- (void)dealloc {
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 点赞
- (void)praiseButtonDidClick:(UIButton *)button
{
    if (button.selected) {
        [MBProgressHUD showError:@"您已经点过赞啦"];
        return;
    }
    if(!UserId || !Token)
    {
        DRLoginViewController * loginVC = [[DRLoginViewController alloc] init];
        [self.viewController presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    if (!self.artId) {
        return;
    }
    
    NSDictionary *bodyDic = @{
                              @"artId":self.artId,
                              };
    
    NSDictionary *headDic = @{
                              @"digest":[DRTool getDigestByBodyDic:bodyDic],
                              @"cmd":@"A23",
                              @"userId":UserId,
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(textViewPraiseDidClick)]) {
                [self.delegate textViewPraiseDidClick];
            }
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}

@end
