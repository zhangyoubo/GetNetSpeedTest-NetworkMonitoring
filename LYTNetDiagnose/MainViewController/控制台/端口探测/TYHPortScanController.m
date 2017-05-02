
//
//  TYHPortScanController.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/10.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "TYHPortScanController.h"
#import "LYTScreenView.h"   
#import "LYTConfig.h"
#import "LYTNetDiagnoser.h"
#import "LYTConfig.h"
#import "LYTNetConnect.h"

@interface TYHPortScanController ()<LDNetConnectDelegate>
{
    NSMutableString *_log;
    LYTScreenView *_screeenView;
    LYTNetConnect * _netConnect;
}

@property (weak, nonatomic) IBOutlet UITextField *domainTextField;
@property (weak, nonatomic) IBOutlet UITextField *conectTimes;
@property (weak, nonatomic) IBOutlet UITextField *conectPort;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
- (IBAction)clickStart:(UIButton *)sender;
- (IBAction)clickAdd:(UIButton *)sender;

@end

@implementation TYHPortScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"端口检测";

    _log = [@"" mutableCopy];
    [self screeenView];
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
        make.top.mas_equalTo(self.startBtn.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.bottom.mas_equalTo(self.view).offset(-15);
    }];
}
- (IBAction)clickStart:(UIButton *)sender {
    if([self.domainTextField.text isIPaddress]){
        _netConnect = [[LYTNetConnect alloc] init];
        _netConnect.delegate = self;
        [_netConnect runWithHostAddress:self.domainTextField.text port:[self.conectPort.text integerValue] maxTestCount:[self.conectTimes.text integerValue]];
    }else{
        //DNS解析
        [[LYTNetDiagnoser shareTool] getDNSFromDomain:self.domainTextField.text respose:^(LYTPingInfo *info) {
            if ([info.infoArray count] > 0) {
        
                for (int i = 0; i < [info.infoArray count]; i++) {
                    _netConnect = [[LYTNetConnect alloc] init];
                    _netConnect.delegate = self;
                    [_netConnect runWithHostAddress:[info.infoArray objectAtIndex:i] port:[self.conectPort.text integerValue] maxTestCount:[self.conectTimes.text integerValue]];
                }
            } else {
                [self addLog:@"DNS解析失败，主机地址不可达"];
            }
        }];
    }
}
#pragma mark - LDNetConnectDelegate
- (void)appendSocketLog:(NSString *)socketLog{
    [self addLog:socketLog];

}
- (void)connectDidEnd:(BOOL)success{
    
    if (success) {
        [self addLog:@"检测完成"];
    }else{
        [self addLog:@"检测失败！"];
    }
    
}


- (IBAction)clickAdd:(UIButton *)sender {
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
