//
//  DRShowTableView.h
//  dr
//
//  Created by 毛文豪 on 2018/12/13.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRSendCommentView.h"

@protocol ShowTableViewDelegate <NSObject>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@optional


@end

@interface DRShowTableView : UITableView

//type 为0 获取自己的，type为1 获取所有用户的
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style userId:(NSString *)userId type:(NSNumber *)type topY:(CGFloat)topY ;

@property (nonatomic, weak) UIImageView * praiseGifImageView;
@property (nonatomic,weak) DRSendCommentView * sendCommentTextView;

/*
 type=1 按时间查询
 type=2 点赞数最多*/
@property (nonatomic, strong) NSNumber *type;

/**
 协议
 */
@property (nonatomic, weak) id <ShowTableViewDelegate> showDelegate;

- (void)getData;
- (void)setupChilds;

@end
