//
//  ReplicatorView.h
//  TransitionDemo
//
//  Created by Apple on 15/7/14.
//  Copyright (c) 2015年 Linitial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReplicatorView : UIView

//@property (nonatomic, strong) UIColor *loadingColor;
//
//@property (nonatomic, assign) NSInteger instanceCount;

+ (void)showReplicatorLoadingInView:(UIView *)superview;

+ (void)disMissReplicatorLoadingInView:(UIView *)view;

@end
