//
//  DRLogisticsTraceModel.m
//  dr
//
//  Created by 毛文豪 on 2017/6/13.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRLogisticsTraceModel.h"
#import "DRDateTool.h"

@implementation DRLogisticsTraceModel

- (CGFloat)cellH
{
    if (_cellH == 0 || _contentAttStr == nil || _isFirst) {
        NSString * timeStr = [NSString stringWithFormat:@"%@",[DRDateTool getTimeByTimestamp:_time format:@"yyyy-MM-dd HH:mm:ss"]];
        NSString * contentStr = [NSString stringWithFormat:@"%@\n\n%@", _desc, timeStr];
        
        NSMutableAttributedString * contentAttStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
        [contentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, _desc.length)];
        [contentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(22)] range:NSMakeRange(_desc.length, contentAttStr.length - _desc.length)];
        if (_isFirst) {
            [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:NSMakeRange(0, contentAttStr.length)];
        }else
        {
            [contentAttStr addAttribute:NSForegroundColorAttributeName value:DRGrayTextColor range:NSMakeRange(0, contentAttStr.length)];
        }
        _contentAttStr = contentAttStr;
        CGSize contentSize = [contentAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * 15 - 10 - DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        _cellH = contentSize.height + 2 * 12;
    }
    return _cellH;
}

@end
