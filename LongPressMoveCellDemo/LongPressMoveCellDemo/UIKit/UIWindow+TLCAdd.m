//
//  UIWindow+TLCAdd.m
//  transaction_list_ios
//
//  Created by xulihua on 2017/12/22.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "UIWindow+TLCAdd.h"

@implementation UIWindow (TLCAdd)

- (CGFloat)TLCBottomSpace {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets.bottom;
    }
    return 0;
}

- (CGFloat)TLCNavigationBarHeight {
    if (@available(iOS 11.0, *)) {
        return MAX(0, self.safeAreaInsets.top-20) + 64;
        
    }
    return 64;
}

@end
