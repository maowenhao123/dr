//
//  DRSystemMessageView.h
//  dr
//
//  Created by 毛文豪 on 2017/10/20.
//  Copyright © 2017年 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRMessageModel.h"

@class DRSystemMessageView;
@protocol SystemMessageViewDelegate <NSObject>

- (void)systemMessageViewDidClick:(DRSystemMessageView *)systemMessageView;

@end

@interface DRSystemMessageView : UIView

@property (nonatomic, weak) UILabel * timeLabel;
@property (nonatomic, weak) UILabel * contentLabel;
@property (nonatomic) NSInteger badge;

@property (nonatomic,strong) DRMessageModel *messageModel;

/**
 协议
 */
@property (nonatomic, weak) id <SystemMessageViewDelegate> delegate;


@end
