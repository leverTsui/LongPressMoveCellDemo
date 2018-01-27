//
//  UIColor+TLCAdd.h
//  LongPressMoveCellDemo
//
//  Created by lever on 2018/1/8.
//  Copyright © 2018年 lever. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TLCAdd)


/**
 Creates and returns a color object from hex string.
 
 @discussion:
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 The alpha will be set to 1.0 if there is no alpha component.
 It will return nil when an error occurs in parsing.
 
 Example: @"0xF0F", @"66ccff", @"#66CCFF88"
 
 @param hexStr  The hex string value for the new color.
 
 @return        An UIColor object from string, or nil if an error occurs.
 */
+ (UIColor *)colorWithHexString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
