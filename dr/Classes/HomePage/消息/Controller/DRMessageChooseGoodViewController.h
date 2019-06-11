//
//  DRMessageChooseGoodViewController.h
//  dr
//
//  Created by 毛文豪 on 2017/12/19.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRSegementViewController.h"

@protocol MessageChooseGoodViewControllerDelegate <NSObject>

- (void)chooseGoodWithArray:(NSArray *)goodArray;

@end

@interface DRMessageChooseGoodViewController : DRSegementViewController


/**
 协议
 */
@property (nonatomic, weak) id <MessageChooseGoodViewControllerDelegate> delegate;


@end
