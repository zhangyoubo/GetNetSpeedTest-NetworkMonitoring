//
//  LYTConfig.h
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/5.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Masonry.h"
#import "LYTSDKDataBase.h"
#import "LYTSDKDataBase+LYTServersList.h"
#import "NSString+NetTool.h"

#define TitleFont 19
#define DestTitleFont 14
#define contentFont 13

#define LYWeakSelf __weak typeof(self) weakSelf = self;
//常见颜色
#define backColor [UIColor colorWithRed:0.757 green:0.875 blue:1.000 alpha:1.000];

//蓝色
#define colorC1D [UIColor colorWithRed:0.757 green:0.875 blue:1.000 alpha:1.000]
#define color8FD [UIColor colorWithRed:0.561 green:0.827 blue:1.000 alpha:1.000]
#define color72c [UIColor colorWithRed:0.447 green:0.784 blue:1.000 alpha:1.000]

#define color01a  [UIColor colorWithRed:0.004 green:0.651 blue:0.996 alpha:1.000]
#define color227shallblue [UIColor colorWithRed:0.133 green:0.478 blue:0.898 alpha:1.000]
#define color004deepblue [UIColor colorWithRed:0.000 green:0.310 blue:0.686 alpha:1.000]
@interface LYTConfig : NSObject

+ (NSArray *)mainViewArray;

@end
