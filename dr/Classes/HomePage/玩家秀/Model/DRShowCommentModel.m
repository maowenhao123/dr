//
//  DRShowCommentModel.m
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRShowCommentModel.h"
#import "DRDateTool.h"

@implementation DRShowCommentModel

- (void)setFrameCellH
{
    CGSize nickNameLabelSize = [_userNickName sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(26)]];
    _nickNameLabelF = CGRectMake(9 + 36 + 5, 9, nickNameLabelSize.width, 36);
    
    _timeStr = [DRDateTool getTimeByTimestamp:_createTime format:@"yyyy-MM-dd HH:mm:ss"];
    CGSize timeLabelSize = [_timeStr sizeWithLabelFont:[UIFont systemFontOfSize:DRGetFontSize(22)]];
    _timeLabelF = CGRectMake(screenWidth - DRMargin - timeLabelSize.width, 9, timeLabelSize.width, 36);

    CGSize commentLabelSize = [[NSString stringWithFormat:@"回复%@：%@", _toUser.nickName, _content] sizeWithFont:[UIFont systemFontOfSize:DRGetFontSize(24)] maxSize:CGSizeMake(screenWidth - _nickNameLabelF.origin.x - DRMargin, MAXFLOAT)];
    _commentLabelF = CGRectMake(_nickNameLabelF.origin.x, CGRectGetMaxY(_nickNameLabelF), commentLabelSize.width, commentLabelSize.height);
    
    CGFloat commentButtonWH = 16;
    _commentButtonF = CGRectMake(screenWidth - DRMargin - commentButtonWH, CGRectGetMaxY(_commentLabelF), commentButtonWH, commentButtonWH);
    
    _cellH = CGRectGetMaxY(_commentButtonF) + 6;
}

- (void)setFrameListCellH
{
    NSString *commentContent = @"";
    if (DRStringIsEmpty(_toUser.nickName) && !DRStringIsEmpty(_userNickName)) {
        commentContent = [NSString stringWithFormat:@"%@：%@", _userNickName, _content];
    }else if (!DRStringIsEmpty(_toUser.nickName) && !DRStringIsEmpty(_userNickName)) {
        commentContent = [NSString stringWithFormat:@"%@回复%@：%@", _userNickName,_toUser.nickName, _content];
    }else
    {
        commentContent = [NSString stringWithFormat:@"%@", _content];
    }
    NSMutableAttributedString * commentContentAttStr = [[NSMutableAttributedString alloc] initWithString:commentContent];
    [commentContentAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DRGetFontSize(24)] range:NSMakeRange(0, commentContentAttStr.length)];
    if (DRStringIsEmpty(_toUser.nickName) && !DRStringIsEmpty(_userNickName)) {
        [commentContentAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[commentContent rangeOfString:_userNickName]];
    }else if (!DRStringIsEmpty(_toUser.nickName) && !DRStringIsEmpty(_userNickName)) {
        if (_userNickName.length > 0) {
            [commentContentAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[commentContent rangeOfString:_userNickName]];
            [commentContentAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[commentContent rangeOfString:_toUser.nickName options:NSCaseInsensitiveSearch range:NSMakeRange([commentContent rangeOfString:_userNickName].location + [commentContent rangeOfString:_userNickName].length, commentContent.length - ([commentContent rangeOfString:_userNickName].location + [commentContent rangeOfString:_userNickName].length))]];
        }
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;//行间距
    [commentContentAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, commentContentAttStr.length)];
    _commentContentAttStr = commentContentAttStr;
    CGSize commentLabelSize = [commentContentAttStr boundingRectWithSize:CGSizeMake(screenWidth - 2 * DRMargin, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    _listCommentLabelF = CGRectMake(DRMargin, 5, commentLabelSize.width, commentLabelSize.height);

    _listCellH = CGRectGetMaxY(_listCommentLabelF) + 5;
}

@end
