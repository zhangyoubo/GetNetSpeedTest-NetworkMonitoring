//
//  LYTDNSViewController.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/7.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "LYTDNSViewController.h"
#import "LYTScreenView.h"
#import "LYTNetDiagnoser.h"
#import "LYTConfig.h"
#import "LYTSDKDataBase+LYTServersList.h"

@interface LYTDNSViewController ()
{
    NSMutableString *_log;
    LYTScreenView *_screeenView;

}
- (IBAction)clickAddbtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *domainTextField;
@property (weak, nonatomic) IBOutlet UIButton *DNSBtn;
- (IBAction)DNSClick:(UIButton *)sender;

@end

@implementation LYTDNSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DNS";
    _log = [@"" mutableCopy];
    [self screeenView];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self stopTraceroute];
}
- (LYTScreenView *)screeenView{
    if (!_screeenView) {
        _screeenView = [[LYTScreenView alloc] initWithContent:@""];
        [self.view addSubview:_screeenView];
    }
    return _screeenView;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_screeenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.DNSBtn.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];
}
- (IBAction)clickAddbtn:(UIButton *)sender {
    [self.view endEditing:YES];
    [[LYTSDKDataBase shareDatabase] dbAllServersSucceed:^(NSArray<NSString *> *servers) {
        __block BOOL exist = NO;
        [servers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:self.domainTextField.text]) {
                exist = YES;
            }
        }];
        if (exist) {
            
            [self addLog:@"该域名主机已经存在\n"];
        }
        else
        {
            [[LYTSDKDataBase shareDatabase] dbInsertserver:self.domainTextField.text succeed:^(BOOL result) {
                [self addLog:@"添加域名主机成功\n"];
            }];
        }
    }];
}
- (IBAction)DNSClick:(UIButton *)sender {
    
    
    [[LYTNetDiagnoser shareTool] getDNSFromDomain:self.domainTextField.text respose:^(LYTPingInfo *info) {
        if (info.infoArray.count == 0) {
            NSString *log = [NSString stringWithFormat:@"%@\n DNS无法解析\n",self.domainTextField.text];
            [self addLog:log];
        }
        else
        {
            NSString *log = [NSString stringWithFormat:@"%@\n %@\n",self.domainTextField.text,info.infoStr];
            [self addLog:log];
        }
    }];
}

- (void)addLog:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_log appendString:log];
        [_log appendString:@"\n"];
        _screeenView.content = _log;
        NSRange range = {_log.length,0};
        [_screeenView scrollToRange:range];
    });
}
@end
