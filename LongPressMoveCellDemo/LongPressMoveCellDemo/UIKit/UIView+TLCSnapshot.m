//
//  UIView+TLCSnapshot.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import "UIView+TLCSnapshot.h"

@implementation UIView (TLCSnapshot)

- (UIView *)snapshotView {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    
    return snapshot;
}

@end
