//
//  DRGoodCommentModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/15.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRGoodCommentModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, copy) NSString * artId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userHeadImg;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *levelDesc;
@property (nonatomic, copy) NSString *specificationId;

//自定义
@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic, assign) NSInteger floor;//第几楼
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, assign) CGRect nickNameLabelF;
@property (nonatomic, assign) CGRect timeLabelF;
@property (nonatomic, assign) CGRect floorLabelF;
@property (nonatomic, assign) CGRect commentLabelF;
@property (nonatomic, assign) CGRect levelLabelF;

@end
