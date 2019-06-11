//
//  DRShowPraiseModel.m
//  dr
//
//  Created by 毛文豪 on 2017/7/16.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowPraiseModel.h"

@implementation DRShowPraiseModel

- (CGFloat)cellH
{
    CGFloat countW = [self getWidthWithText:[NSString stringWithFormat:@"%@", _praiseCount]];
    CGFloat x = DRMargin;
    CGFloat y = 6;
    CGFloat w = 15 + 5 + countW;
    CGFloat h = [UIFont systemFontOfSize:DRGetFontSize(26)].lineHeight;
    CGFloat paddingW = 5;
    CGFloat paddingH = 4;
    _praiseButtonFs = [NSMutableArray array];
    for (int i = 0; i < _praiseList.count + 1; i++) {
        CGRect rect;
        if (i == 0) {
            rect = CGRectMake(x, y, w, h);
        }else
        {
            DRPraiseUserModel * user = _praiseList[i - 1];
            if (i == _praiseList.count) {
                w = [self getWidthWithText:user.userNickName];
            }else
            {
                w = [self getWidthWithText:[NSString stringWithFormat:@"%@,", user.userNickName]];
            }
            if (x + w + DRMargin > screenWidth) {
                y += h + paddingH;
                x = DRMargin;
            }
            rect = CGRectMake(x, y, w, h);
            if (i == _praiseList.count) {
                _cellH = y + h + 6;
            }
        }
        x += w + paddingW;
        [_praiseButtonFs addObject:[NSValue valueWithCGRect:rect]];
    }
    
    return _cellH;
}
- (CGFloat)getWidthWithText:(NSString *)text
{
    CGFloat width = [text sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(26)]].width;
    return width > (screenWidth - 2 * DRMargin) ? (screenWidth - 2 * DRMargin) : width;
}

@end
