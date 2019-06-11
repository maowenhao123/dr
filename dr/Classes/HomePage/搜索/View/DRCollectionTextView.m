//
//  DRCollectionTextView.m
//  dr
//
//  Created by 毛文豪 on 2017/3/29.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRCollectionTextView.h"

@interface DRCollectionTextView ()

@property (nonatomic, assign) CGFloat viewHeight;

@end

@implementation DRCollectionTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textFont = [UIFont systemFontOfSize:DRGetFontSize(26)];//默认字体大小
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textFont = [UIFont systemFontOfSize:DRGetFontSize(26)];//默认字体大小
    }
    return self;
}
- (void)setTexts:(NSArray *)texts
{
    _texts = texts;
    for (UIView * subView in self.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat x = DRMargin;
    CGFloat y = 0;
    CGFloat w = [self getWidthWithText:_texts.firstObject] + 28;
    CGFloat h = 30;
    CGFloat paddingW = 8;
    CGFloat paddingH = 9;
    for (int i = 0; i < _texts.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        w = [self getWidthWithText:_texts[i]] + 28;
        if (x + w + DRMargin > screenWidth) {
            y += h + paddingH;
            x = DRMargin;
        }
        button.frame = CGRectMake(x, y, w, h);
        button.backgroundColor = DRColor(242, 242, 242, 1);
        [button setTitle:_texts[i] forState:UIControlStateNormal];
        [button setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
        button.titleLabel.font = self.textFont;
        button.layer.cornerRadius = 15;
        x += w + paddingW;
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (i == _texts.count - 1) {
            self.viewHeight = y + h;
        }
    }
}
- (CGFloat)getWidthWithText:(NSString *)text
{
    CGFloat width = [text sizeWithLabelFont:self.textFont].width;
    return width > (screenWidth - 2 * DRMargin - 28) ? (screenWidth - 2 * DRMargin - 28) : width;
}
- (CGFloat)getViewHeight
{
    return self.viewHeight;
}
- (void)buttonDidClick:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionTextViewButtonDidClick:)]) {
        [_delegate collectionTextViewButtonDidClick:button];
    }
}

@end
