//
//  MUIGrowingTextView.h
//  JiMeiUnv
//
//  Created by weikunliang on 14-9-5.
//  Copyright (c) 2014年 nd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUITextViewInternal.h"
#import <UIKit/UIKit.h>


@class MUIGrowingTextView;

// 继承UItextView的代理
@protocol MUIGrowingTextViewDelegate

@optional
//UItextView的代理,命名与UITextViewDelegate的代理相匹配
- (BOOL)growingTextViewShouldBeginEditing:(MUIGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(MUIGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(MUIGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(MUIGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(MUIGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(MUIGrowingTextView *)growingTextView;

- (void)growingTextViewDidChangeSelection:(MUIGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(MUIGrowingTextView *)growingTextView;

//高度自增长时的代理(将要修改高度)
- (void)growingTextView:(MUIGrowingTextView *)growingTextView willChangeHeight:(float)height;

//高度自增长时的代理(已经修改高度)
- (void)growingTextView:(MUIGrowingTextView *)growingTextView didChangeHeight:(float)height;
@end


@interface MUIGrowingTextView : UIView <UITextViewDelegate, MUIGrowingTextViewDelegate>{
    NSObject <MUIGrowingTextViewDelegate>* __weak  delegate;
}

//内部textview，文本的实际载体
@property (nonatomic, strong) MUITextViewInternal *internalTextView;

//最多显示行数
@property (nonatomic, assign) NSInteger maxNumberOfLines;

//最少显示行数
@property (nonatomic, assign) NSInteger minNumberOfLines;

//最大行高
@property (nonatomic, assign) NSInteger maxHeight;

//最少行高
@property (nonatomic, assign) NSInteger minHeight;

// 预显示文字
@property (nonatomic, copy) NSString *placeholder;

//预显示文字颜色
@property (nonatomic, assign) UIColor *placeholderColor;

//高度变化动画时长
@property (nonatomic, assign) NSTimeInterval animationDuration;

//允许高度变化动画
@property (nonatomic, assign) BOOL allowAnimation;

//事件代理
@property (nonatomic, weak) id<MUIGrowingTextViewDelegate> delegate;

// UItextview 基本属性
//文本
@property (nonatomic, strong) NSString *text;

//字体
@property (nonatomic, strong) UIFont *font;

//字体颜色
@property (nonatomic, strong) UIColor *textColor;

//文字位置
@property (nonatomic) NSTextAlignment textAlignment;

//选中区域
@property (nonatomic) NSRange selectedRange;

//可编辑
@property (nonatomic, getter=isEditable) BOOL editable;

//内容链接显示类型
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);

//返回按钮的类型
@property (nonatomic) UIReturnKeyType returnKeyType;

//键盘类型
@property (nonatomic) UIKeyboardType keyboardType;

//边距
@property (assign) UIEdgeInsets contentInset;

//可滚动
@property (nonatomic) BOOL isScrollable;

//可回车返回
@property (nonatomic) BOOL enablesReturnKeyAutomatically;

//富媒体文本
@property (nonatomic) NSMutableAttributedString *attributedText;

//响应触发
-(BOOL)becomeFirstResponder;

//取消响应触发
-(BOOL)resignFirstResponder;

//是否响应触发
-(BOOL)isFirstResponder;

//是否有文本内容
-(BOOL)hasText;

//滑动到指定位置
-(void)scrollRangeToVisible:(NSRange)range;

//强制刷新高度
-(void)refreshHeight;

@end

