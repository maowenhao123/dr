//
//  DRVideoFloatingWindow.h
//  dr
//
//  Created by 毛文豪 on 2018/12/19.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLPlayerView.h"

typedef enum {
    BannerVideoFloatingWindow = 0,  //在banner
    SmallVideoFloatingWindow,   //小窗口
} FloatingWindowType;

NS_ASSUME_NONNULL_BEGIN

@interface DRVideoFloatingWindow : UIView

@property (nonatomic, strong) CLPlayerView *playerView;
@property (nonatomic, weak) UIView *barView;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) FloatingWindowType floatingWindowType;//1 2

@end

NS_ASSUME_NONNULL_END
