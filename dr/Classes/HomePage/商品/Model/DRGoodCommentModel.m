//
//  DRGoodCommentModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGoodCommentModel.h"
#import "DRDateTool.h"

@implementation DRGoodCommentModel

- (CGFloat)cellH
{
    CGSize nickNameLabelSize = [_userNickName sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(26)]];
    _nickNameLabelF = CGRectMake(9 + 36 + 5, 9, nickNameLabelSize.width, 36);
    
    _timeStr = [DRDateTool getTimeByTimestamp:_createTime format:@"yyyy-MM-dd HH:mm:ss"];
    CGSize timeLabelSize = [_timeStr sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(22)]];
    _timeLabelF = CGRectMake(screenWidth - DRMargin - timeLabelSize.width, 9, timeLabelSize.width, 36);
    
    CGSize commentLabelSize = [_content sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - _nickNameLabelF.origin.x - DRMargin, MAXFLOAT)];
    _commentLabelF = CGRectMake(_nickNameLabelF.origin.x, CGRectGetMaxY(_nickNameLabelF), commentLabelSize.width, commentLabelSize.height);
    
    _cellH = CGRectGetMaxY(_commentLabelF) + 10;
    return _cellH;
}


@end
