//
//  UIColor+TYHColor.m
//  TaiYangHua
//
//  Created by Vieene on 16/8/1.
//  Copyright © 2016年 hhly. All rights reserved.
//

#import "UIColor+TYHColor.h"

@implementation UIColor (TYHColor)
/**
 * 将16进制颜色转换成UIColor
 *
 **/
+(UIColor *)getColor:(NSString *)hexColor {
    return [self getColor:hexColor alpha:1.0]; // modify by zhangsg 2016.11.14
}

+(UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha {

    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:alpha];

}

@end
