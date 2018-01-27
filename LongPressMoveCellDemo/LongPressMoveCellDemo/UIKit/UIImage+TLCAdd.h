//
//  UIImage+TLCAdd.h
//  LongPressMoveCellDemo
//
//  Created by lever on 2018/1/8.
//  Copyright © 2018年 lever. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TLCAdd)

/**
 Create and return a pure color image with the given color and size.
 
 @param color  The color.
 @param size   New image's type.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
