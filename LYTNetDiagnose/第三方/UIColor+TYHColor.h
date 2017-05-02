//
//  UIColor+TYHColor.h
//  TaiYangHua
//
//  Created by Vieene on 16/8/1.
//  Copyright © 2016年 hhly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (TYHColor)
/**
 * 将16进制颜色转换成UIColor
 *
 **/
+(UIColor *)getColor:(NSString *)hexColor;

/**
 * 将16进制颜色转换成UIColor 设置透明度 (add by zhangsg 2016.11.14)
 *
 **/
+(UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha;
@end
