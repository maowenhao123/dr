//
//  DRShowCommentModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/8.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRShowCommentModel : NSObject

@property (nonatomic, copy) NSString * artId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) long long createTime;
@property (nonatomic, copy) NSString *userHeadImg;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic,copy) NSString *userLoginName;
@property (nonatomic, copy) NSString *userNickName;
@property (nonatomic,strong) DRUser *toUser;

//自定义
@property (nonatomic,assign) BOOL isFirst;

@property (nonatomic, assign) CGFloat cellH;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, assign) CGRect nickNameLabelF;
@property (nonatomic, assign) CGRect timeLabelF;
@property (nonatomic, assign) CGRect commentLabelF;
@property (nonatomic, assign) CGRect commentButtonF;

@property (nonatomic, assign) CGFloat listCellH;
@property (nonatomic,copy) NSAttributedString *commentContentAttStr;
@property (nonatomic, assign) CGRect listCommentLabelF;

- (void)setFrameCellH;
- (void)setFrameListCellH;

@end
