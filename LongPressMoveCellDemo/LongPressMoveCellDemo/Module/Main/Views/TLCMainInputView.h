//
//  TLCMainInputView.h
//  transaction_list_ios
//
//  Created by lever on 2017/12/26.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MUIGrowingTextView.h"

@class TLCMainInputView;

@protocol TLCMainInputViewDeletate<NSObject>

- (void)mainInputView:(TLCMainInputView *)view creatProjectAtIndexPath:(NSIndexPath *)indexPath;

//高度自增长时的代理(将要修改高度)
- (void)mainInputGrowingTextView:(MUIGrowingTextView *)growingTextView willChangeHeight:(CGFloat)height;

@end

@interface TLCMainInputView : UIView

@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 代理
 */
@property (nonatomic, weak) id<TLCMainInputViewDeletate> delegate;

/**
 成为第一响应，弹出键盘
 */
- (void)textViewBecomeFirstResponder;

/**
 获取输入文本

 @return 输入文本
 */
- (NSString *)inputText;

/**
 重置，将文本置为nil
 */
- (void)resetText;


@end
