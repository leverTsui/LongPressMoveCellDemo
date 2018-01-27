//
//  MUPInnerTextView.h
//  JiMeiUnv
//
//  Created by weikunliang on 14-9-5.
//  Copyright (c) 2014年 nd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MUITextViewInternal : UITextView

//提示文本
@property (nonatomic ,retain) NSString *placeholder;

//提示文本颜色
@property (nonatomic ,retain) UIColor *placeholderColor;

//滑动到光标处
-(void) scrollToEditingRange;

//根据新的文本内容决定是否显示提示文本placeholder
-(void) textChanged;
@end
