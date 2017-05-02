//
//  UIImage+Extension.m
//  SportsFans
//
//  Created by qianfeng on 15/11/26.
//  Copyright (c) 2015年 1000phone. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


+(instancetype)imageWithOriginalImageName:(NSString *)imageName{
    
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

@end
