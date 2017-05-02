//
//  LYTColorRank.m
//  LYTNetDiagnose
//
//  Created by Vieene on 2017/3/24.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTColorRank.h"

@implementation LYTColorRank
+ (UIColor *)pingColorWithDurationTime:(NSString *)durationTime{
    CGFloat time = [durationTime floatValue];
    if (time <= 100 && time != 0) {
        int greenRank = time/10;
        switch (greenRank) {
            case 0:
                return [UIColor greenColor];
                break;
            case 1:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.9];
                break;
            case 2:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.8];
                break;
            case 3:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.7];
                break;
            case 4:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
                break;
            case 5:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
                break;
            case 6:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.4];
                break;
            case 7:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
                break;
            case 8:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2];
                break;
            case 9:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.1];
                break;
            case 10:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:0.1];
                break;
            default:
                return [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                break;
        }
    }else if(time > 100&& time != 0){
        int readRank = time/100;
        switch (readRank) {
            case 1:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.1];
                break;
            case 2:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.2];
                break;
            case 3:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
                break;
            case 4:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.4];
                break;
            case 5:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
                break;
            case 6:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
                break;
            case 7:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.7];
            case 8:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8];
                break;
            case 9:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.9];
                break;
            case 10:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
                break;
            default:
                return [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
                break;
        }
    }
    return [UIColor blackColor];
}
@end
