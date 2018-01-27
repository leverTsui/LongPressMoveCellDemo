//
//  TLCMainNoResultView.m
//  transaction_list_ios
//
//  Created by lever on 2018/1/2.
//  Copyright © 2018年 ND. All rights reserved.
//

#import "TLCMainNoResultView.h" 
#import "TLCDefine.h"
#import <Masonry/Masonry.h>
#import "UIColor+TLCAdd.h"

@interface TLCMainNoResultView ()

@property (nonatomic, strong) TLCNoResultViewModel *model;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation TLCMainNoResultView

- (instancetype)initWithFrame:(CGRect)frame
                        model:(TLCNoResultViewModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        self.model = model;
        [self configurePageView];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (void)configurePageView {
    
}

- (void)addPageSubviews {
    //图片
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = TLCSkinImage(self.model.imageName);
    
    [self addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"6f6f6f"];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.text = self.model.title;
    
    [self addSubview:self.titleLabel];
    
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.font =  [UIFont systemFontOfSize:12];;
    self.tipLabel.textColor = [UIColor colorWithHexString:@"9e9e9e"];;
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.tipLabel.text = self.model.tip;
    
    [self addSubview:self.tipLabel];
}

- (void)layoutPageSubviews {
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.imageView.image.size.width);
        make.height.mas_equalTo(self.imageView.image.size.height);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(21);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(self.titleLabel.font.lineHeight);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(self.tipLabel.font.lineHeight);
        make.bottom.equalTo(self);
    }];
    
}

#pragma mark - public
- (void)reloadWithModel:(TLCNoResultViewModel *)model {
    
    self.imageView.image = TLCSkinImage(model.imageName);
    
    self.titleLabel.text = model.title;
    self.tipLabel.text = model.tip;
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.imageView.image.size.width);
        make.height.mas_equalTo(self.imageView.image.size.height);
    }];
}


@end
