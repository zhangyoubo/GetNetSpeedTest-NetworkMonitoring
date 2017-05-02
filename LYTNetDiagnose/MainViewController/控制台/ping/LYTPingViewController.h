//
//  LYTPingViewController.h
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/27.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "TYHBaseViewController.h"
@protocol LYTPingViewControllerDelegate <NSObject>

/**
开始ping一个地址

 @param address 地址／主机或者域名
 */
- (void)pingViewControllerStartPingAddress:(NSString *)address count:(NSInteger)count;

/**
 停止ping一个地址
 */
- (void)pingViewControllerStopPing;
@end
@interface LYTPingViewController : TYHBaseViewController
@property (nonatomic,weak)id <LYTPingViewControllerDelegate>delegate;
- (void)didEndPingAction;
@end
