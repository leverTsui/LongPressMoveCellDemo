//
//  TLCPlaceholderTextView.h
//  transaction_list_ios
//
//  Created by lever on 2017/12/27.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLCPlaceholderTextView : UITextView

/**
 占位文字
 */
@property (nonatomic, copy) NSString *placeholder; 

/**
 占位文字颜色
 */
@property (nonatomic, strong) UIColor *placeholderColor;

@end
