//
//  YZSortButton.h
//  dr
//
//  Created by 毛文豪 on 2018/11/1.
//  Copyright © 2018 JG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SortModeNormal = 0,  //不排序
    SortModeAscending,   //升序
    SortModeDescending,  //降序
} SortMode;

@interface YZSortButton : UIButton

- (instancetype)initWithShowImage:(BOOL)showImage;

@property (nonatomic, copy) NSString *text;//标题

@property (nonatomic, assign) SortMode sortMode;//排序的状态

@end

