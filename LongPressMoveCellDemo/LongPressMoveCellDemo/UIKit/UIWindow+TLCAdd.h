//
//  UIWindow+TLCAdd.h
//  transaction_list_ios
//
//  Created by xulihua on 2017/12/22.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (TLCAdd)

/**
 获取安全区域底部的高度

 @return 安全区域底部的高度
 */
- (CGFloat)TLCBottomSpace;

/**
 获取导航栏的高度

 @return 导航栏的高度
 */
- (CGFloat)TLCNavigationBarHeight;

@end
