//
//  DRChooseRedPacketViewController.h
//  dr
//
//  Created by 毛文豪 on 2018/1/31.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRBaseViewController.h"
#import "DRRedPacketModel.h"

@protocol ChooseRedPacketViewControllerDelegate <NSObject>

- (void)didChooseRedPacket:(DRRedPacketModel *)redPacketModel;
- (void)cancelRedPacket;

@end

@interface DRChooseRedPacketViewController : DRBaseViewController

/**
 协议
 */
@property (nonatomic, weak) id <ChooseRedPacketViewControllerDelegate> delegate;

@property (nonatomic,copy) NSString *couponUserId;

@property (nonatomic,assign) double orderPrice;

@end
