//
//  TYHBaseViewController.m
//  TaiYangHua
//
//  Created by Vieene on 15/12/28.
//  Copyright © 2015年 hhly. All rights reserved.
//

#import "TYHBaseViewController.h"

@interface TYHBaseViewController ()

@end

@implementation TYHBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kMainViewBgColor;
    
    [self setleftBarButton];
    [self setNavTitleColor];
   
}
- (void)setleftBarButton
{

    UIButton *btn = [[UIButton alloc] init];
    [btn addTarget:self action:@selector(clickBackBarItem) forControlEvents:UIControlEventTouchDown];
    [btn setImage:[UIImage imageNamed:@"backImage"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 50, 40);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = baritem;

}
- (void)setNavTitleColor
{
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
}
- (void)clickBackBarItem
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
