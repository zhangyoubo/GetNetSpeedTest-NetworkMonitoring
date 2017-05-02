//
//  MainViewCell.m
//  LYTNetDiagnose
//
//  Created by 谭建中 on 2017/4/5.
//  Copyright © 2017年 Vieene. All rights reserved.
//

#import "MainViewCell.h"
#import "MainViewModel.h"
#import "LYTConfig.h"

#import "UIView+SDAutoLayout.h"
#import "UITableView+SDAutoTableViewCellHeight.h"

#define W(x) kScreenWidth*(x)/320.0
#define H(y) kScreenHeight*(y)/568.0
#define kMarg 10
#define kHeightLabel 30

@implementation MainViewCell{
    UILabel *_titleLabel;
    UILabel *_contentLabel;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubviews];
    }
    return self;
}
-(void)addSubviews{

    
    UIImageView *lineView = [UIImageView new];
    lineView.backgroundColor = kMainViewBgColor;
    [self.contentView addSubview:lineView];
    
    _titleLabel = [UILabel new];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor colorWithRed:249.0/255 green:123.0/255 blue:134.0/255 alpha:100];
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:100];
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.numberOfLines = 0;
    _contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_contentLabel];
    
    
    lineView.sd_layout.widthIs(kScreenWidth).heightIs(kMarg).topSpaceToView(self.contentView,0);
    
    _titleLabel.sd_layout.widthIs(kScreenWidth - kMarg *4).heightIs(kHeightLabel).topSpaceToView(lineView, kMarg).leftSpaceToView(self.contentView,kMarg * 2);
    
    _contentLabel.sd_layout.topSpaceToView(_titleLabel, kMarg).rightSpaceToView(self.contentView, kMarg * 2).leftSpaceToView(self.contentView,kMarg * 2).autoHeightRatio(0);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)setModel:(MainViewModel *)model{
    
    _model = model;
    _titleLabel.text = model.title;
    _contentLabel.text = model.desTitle;
  
    
    //***********************高度自适应cell设置步骤************************
    [self setupAutoHeightWithBottomView:_contentLabel bottomMargin:20];
}
@end
