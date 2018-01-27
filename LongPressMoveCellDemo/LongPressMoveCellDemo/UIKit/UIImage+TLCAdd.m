//
//  UIImage+TLCAdd.m
//  LongPressMoveCellDemo
//
//  Created by lever on 2018/1/8.
//  Copyright © 2018年 lever. All rights reserved.
//

#import "UIImage+TLCAdd.h"

@implementation UIImage (TLCAdd)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
