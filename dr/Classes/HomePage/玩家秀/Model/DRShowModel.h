//
//  DRShowModel.h
//  dr
//
//  Created by 毛文豪 on 2017/5/4.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRShowPraiseModel.h"
#import "DRShowCommentModel.h"

@interface DRShowModel : NSObject

@property (nonatomic, strong) NSNumber * commentCount;//评论数
@property (nonatomic, copy) NSString * content;//内容
@property (nonatomic, assign) long long createTime;//创建时间
@property (nonatomic, strong) NSNumber * focusCount;//关注数
@property (nonatomic, copy) NSString * id;
@property (nonatomic, copy) NSString * name;//名字
@property (nonatomic, copy) NSString * pics;//图片
@property (nonatomic, strong) NSNumber * praiseCount;//点赞数
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, copy) NSString * userHeadImg;//用户头像
@property (nonatomic, copy) NSString * userId;//用户id
@property (nonatomic, copy) NSString * userNickName;//用户昵称
@property (nonatomic,strong) NSNumber *userType;//type为1时，已开店

//自定义
@property (nonatomic, strong) DRShowPraiseModel * showPraiseModel;
@property (nonatomic,strong) NSArray *commentArray;
@property (nonatomic,assign) NSInteger index;

@property (nonatomic, assign)CGRect titleLabelF;
@property (nonatomic, copy) NSMutableAttributedString * detailAttStr;
@property (nonatomic, assign)CGRect detailLabelF;
@property (nonatomic,assign) CGRect triangleImageViewF;
@property (nonatomic, assign) CGFloat headerViewH;

- (void)setFrameCellH;

@end
