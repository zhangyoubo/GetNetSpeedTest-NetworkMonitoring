//
//  LYTScreenView.h
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/5.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYTScreenView : UIView
- (instancetype)initWithFilepath:(NSString *)path;
- (instancetype)initWithContent:(NSString *)content;
@property (copy,nonatomic) NSString *content;

/**
 滑动到什么位置
 */
- (void)scrollToRange:(NSRange)range;
@end
