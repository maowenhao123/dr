//
//  DRPraiseSectionModel.m
//  dr
//
//  Created by 毛文豪 on 2018/12/27.
//  Copyright © 2018 JG. All rights reserved.
//

#import "DRPraiseSectionModel.h"

@implementation DRPraiseSectionModel

- (NSMutableArray *)praiseList
{
    if(_praiseList == nil)
    {
        _praiseList = [NSMutableArray array];
    }
    return _praiseList;
}

- (NSMutableArray *)awardList
{
    if(_awardList == nil)
    {
        _awardList = [NSMutableArray array];
    }
    return _awardList;
}

- (CGFloat)cellH
{
    CGFloat maxY = 0;
    if ([_type intValue] == 1) {
        _weekViewF = CGRectMake(0, 0, screenWidth, 35);
        maxY = CGRectGetMaxY(_weekViewF);
    }else
    {
        _weekViewF = CGRectZero;
        maxY = 10;
    }
    if (_awardList.count > 0) {//中奖
        DRAwardModel *awardModel = _awardList.firstObject;
        if ([awardModel.status intValue] == 1) {//已经领取
            if ([awardModel.receiveType intValue] == 1) {//已经领取多肉
                _resultLabelF = CGRectZero;
                _goodAwardViewF = CGRectMake(0, maxY, screenWidth, 50);
                _redPacketAwardViewF = CGRectZero;
                maxY = CGRectGetMaxY(_goodAwardViewF);
            }else if ([awardModel.receiveType intValue] == 2)//已经领取红包
            {
                _resultLabelF = CGRectZero;
                _goodAwardViewF = CGRectZero;
                _redPacketAwardViewF = CGRectMake(0, maxY, screenWidth, 50);
                maxY = CGRectGetMaxY(_redPacketAwardViewF);
            }
        }else
        {
            _resultLabelF = CGRectMake(40, maxY + 5, screenWidth - 2 * 40, 20);
            maxY = CGRectGetMaxY(_resultLabelF);
            _redPacketAwardViewF = CGRectMake(0, maxY, screenWidth, 50);
            maxY = CGRectGetMaxY(_redPacketAwardViewF);
            _goodAwardViewF = CGRectMake(0, maxY, screenWidth, 50);
            maxY = CGRectGetMaxY(_goodAwardViewF);
        }
    }else//未中奖
    {
        _resultLabelF = CGRectMake(40, maxY + 5, screenWidth - 2 * 40, 20);
        _goodAwardViewF = CGRectZero;
        _redPacketAwardViewF = CGRectZero;
        maxY = CGRectGetMaxY(_resultLabelF);
    }
    _cellH = maxY + 15;
   
    return _cellH;
}

@end
