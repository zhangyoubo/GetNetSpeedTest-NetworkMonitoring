//
//  ReplicatorView.m
//  TransitionDemo
//
//  Created by Apple on 15/7/14.
//  Copyright (c) 2015年 Linitial. All rights reserved.
//

#import "ReplicatorView.h"

@interface ReplicatorView ()

@property (nonatomic, strong) CAReplicatorLayer *repLayer;
@property (nonatomic, strong) CAShapeLayer *insLayer;
@property (nonatomic, strong) CABasicAnimation *animation;

@end

CGFloat const kLoadingWidth = 200.0;

@implementation ReplicatorView

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
//        self.instanceCount = 20.0;
    }
    return self;
}

- (void)setupLayers {
    
    _repLayer = [CAReplicatorLayer layer];
    _repLayer.frame = self.bounds;
    _repLayer.instanceCount = 20;
    _repLayer.preservesDepth = NO;
    _repLayer.instanceDelay = 1/20.0;
    _repLayer.instanceColor = [UIColor whiteColor].CGColor;
    _repLayer.instanceTransform = CATransform3DMakeRotation((M_PI*2.0)/18, 0.0, 0.0, 1.0);
    
    _insLayer = [CAShapeLayer layer];
    _insLayer.frame = CGRectMake(self.bounds.size.width/2.0, 0.0, 6.0, 6.0);
    _insLayer.cornerRadius = 6.0/2;
    _insLayer.backgroundColor = kMainScreenColor.CGColor;
    [_repLayer addSublayer:_insLayer];
    
    _animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    _animation.fromValue = @0.5;
    _animation.toValue = @1.5;
    _animation.repeatCount = HUGE;
    _animation.duration = 1.;
    [_insLayer addAnimation:_animation forKey:nil];
    [self.layer addSublayer:_repLayer];
}

+ (void)showReplicatorLoadingInView:(UIView *)superview{
    if ([self loadingHUDForView:superview]) {
        return;
    }
    ReplicatorView *loadingView = [[ReplicatorView alloc] initWithView:superview];
    loadingView.frame = CGRectMake(0, 0, kLoadingWidth, kLoadingWidth);
    loadingView.center = superview.center;
    [superview addSubview:loadingView];
    
    [loadingView show];
}

- (void)show {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setupLayers];
}

+ (void)disMissReplicatorLoadingInView:(UIView *)view {
    ReplicatorView *loading = [self loadingHUDForView:view];
    if (loading != nil) {
        [loading hide];
    }
}

- (void)hide {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        _insLayer = nil;
        _repLayer = nil;
        [self removeFromSuperview];
    }];
}

+ (id)loadingHUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (ReplicatorView *)subview;
        }
    }
    return nil;
}


- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
