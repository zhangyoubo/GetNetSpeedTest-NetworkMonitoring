//
//  AboutVC.m
//  SpeedTest
//
//  Created by shen on 17/4/17.
//  Copyright © 2017年 shen. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()

@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"关于APP";
    [self aboutAPP];
}

-(void)aboutAPP{
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 150)];
    header.backgroundColor = kMainScreenColor;
    [self.view addSubview:header];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2, (header.bounds.size.height - 120)/2, 100, 100)];
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.image = [UIImage imageNamed:@"logoimage"];
    [header addSubview:imageView];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(imageView.frame)+ 5 , kScreenWidth,20)];
    label.text = [NSString stringWithFormat:@"版本号:%@(%@)",app_Version,app_build];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    [header addSubview:label];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20,CGRectGetMaxY(header.frame)+ 10 ,kScreenWidth - 40, 160)];
    textView.text = @"     APP集成了网络测速以及网络监控。方便检查网络的2G、3G、4G、WiFi的网速问题;单独的ping测试功能、Traceroute检测功能、DNS检测功能、端口检测等。简单易用的网络检测工具。";
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    
    static CGFloat maxHeight = 160.0f;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight){
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else{
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height );
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
