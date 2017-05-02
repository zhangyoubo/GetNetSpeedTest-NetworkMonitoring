//
//  EPProgressShow.h
//  ExpressionPackage-Demo
//
//  Created by shen on 17/3/23.
//  Copyright © 2017年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPProgressShow : NSObject

+ (instancetype)showHUDManager;

- (void)showInfoWithStatus:(NSString *)status;

- (void)showErrorWithStatus:(NSString *)status;

- (void)showSuccessWithStatus:(NSString *)status;

@end
