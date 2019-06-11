//
//  DRSendCommentView.h
//  dr
//
//  Created by 毛文豪 on 2017/7/17.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRTextView.h"

@protocol SendCommentViewDelegate <NSObject>

@optional
- (void)textViewChangeHeight:(CGFloat)height;
- (void)textViewSendButtonDidClickWithText:(NSString *)text;
- (void)textViewPraiseDidClick;

@end

@interface DRSendCommentView : UIView

@property (nonatomic,weak) DRTextView * textView;
@property (nonatomic,weak) UIButton * sendButton;
@property (nonatomic, weak) UIButton * praiseButton;
@property (nonatomic, weak) id<SendCommentViewDelegate> delegate;
@property (nonatomic,copy) NSString *artId;
@property (nonatomic,copy) NSString *toUserId;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSIndexPath *indexPath;

- (void)reset;

@end
