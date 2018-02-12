//
//  TLCMainInputView.m
//  transaction_list_ios
//
//  Created by lever on 2017/12/26.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "TLCMainInputView.h" 
#import <Masonry/Masonry.h>
#import "TLCDefine.h"
#import "UIColor+TLCAdd.h"
#import "UIImage+TLCAdd.h"

@interface TLCMainInputView ()<MUIGrowingTextViewDelegate>

@property (nonatomic, strong) MUIGrowingTextView *textView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) UIView *separateLine;

@end

@implementation TLCMainInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurePageView];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (void)configurePageView {
    self.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
}

- (void)addPageSubviews {
    [self addSubview:self.separateLine];
    [self addSubview:self.textView];
    [self addSubview:self.cancelButton];
    [self addSubview:self.createButton];
}

- (void)layoutPageSubviews {
    [self.separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.leading.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-10);
        make.height.mas_greaterThanOrEqualTo(34);
        make.bottom.equalTo(self.cancelButton.mas_top).offset(-8);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(55);
        
        make.trailing.equalTo(self.createButton.mas_leading).offset(-13);
        make.bottom.equalTo(self).offset(-10);
    }];
    
    [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelButton);
        make.width.equalTo(self.cancelButton);
        make.height.equalTo(self.cancelButton);
        make.trailing.equalTo(self).offset(-8);
    }]; 
}

#pragma mark - event response

- (void)cancelButtonClicked:(UIButton *)sender {
     [self retractKeyboard];
}

- (void)createButtonClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainInputView:creatProjectAtIndexPath:)]) {
        [self.delegate mainInputView:self creatProjectAtIndexPath:self.indexPath];
    }
    [self retractKeyboard];
}

#pragma mark - public

- (void)textViewBecomeFirstResponder {
    [self.textView becomeFirstResponder];
}

- (NSString *)inputText {
    return self.textView.text;
}

- (void)resetText {
    self.textView.text = nil;
}

#pragma mark - private
- (void)retractKeyboard {
    
    [self.textView resignFirstResponder];
    if (self.textView.text.length > 0) {
        [self resetText];
    }
}

#pragma mark - MUIGrowingTextViewDelegate

//高度自增长时的代理(将要修改高度)
- (void)growingTextView:(MUIGrowingTextView *)growingTextView willChangeHeight:(float)height {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainInputGrowingTextView:willChangeHeight:)]) {
        [self.delegate mainInputGrowingTextView:growingTextView willChangeHeight:height>34 ? height:34];
    }
}

- (void)growingTextViewDidChange:(MUIGrowingTextView *)growingTextView { 
    NSString *text = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.createButton.enabled = text.length>0;
}
 
//高度自增长时的代理(已经修改高度)
- (void)growingTextView:(MUIGrowingTextView *)growingTextView didChangeHeight:(float)height {
    [self layoutIfNeeded];
}

#pragma mark - getter & setter

- (MUIGrowingTextView *)textView {
    if (!_textView) { 
        _textView= [[MUIGrowingTextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor]; 
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.internalTextView.enablesReturnKeyAutomatically = YES;
        _textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.internalTextView.scrollsToTop = NO;
        _textView.maxHeight = 70;
        _textView.delegate = self;
        _textView.maxNumberOfLines = 3;
        _textView.minNumberOfLines = 1;
        _textView.minHeight = 34;
        _textView.maxHeight = 70;
        _textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        _textView.placeholder = TLCLocalizedString(@"TLC_Main_Input_View_Placeholder");
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _textView.layer.masksToBounds = YES;
        _textView.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.cornerRadius = 4.0;
        _textView.clipsToBounds = YES;
    }
    return _textView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton setTitle:TLCLocalizedString(@"TLC_Main_Input_View_Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"cccccc"] forState:UIControlStateNormal];
        
        _cancelButton.layer.cornerRadius = 4.0;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.borderColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
        _cancelButton.layer.borderWidth = 0.5;
        
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)createButton {
    if (!_createButton) {
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _createButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_createButton setTitle:TLCLocalizedString(@"TLC_Main_Input_View_Create") forState:UIControlStateNormal];
        [_createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImage *backgroundImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"38adff"] size:CGSizeMake(55, 26)];
 
        UIImage *disableBackgroundImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"999999"] size:CGSizeMake(55, 26)];
        
        [_createButton setBackgroundImage:backgroundImage
                        forState:UIControlStateNormal];
        [_createButton setBackgroundImage:backgroundImage
                            forState:UIControlStateHighlighted];
        [_createButton setBackgroundImage:disableBackgroundImage
                        forState:UIControlStateDisabled];
        _createButton.enabled = NO;
        _createButton.layer.cornerRadius = 4.0;
        _createButton.layer.masksToBounds = YES;
        
        [_createButton addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventTouchUpInside]; 
    }
    return _createButton;
}

- (UIView *)separateLine {
    if (!_separateLine) {
        _separateLine = [[UIView alloc] init];
        _separateLine.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
    }
    return _separateLine;
}

@end
