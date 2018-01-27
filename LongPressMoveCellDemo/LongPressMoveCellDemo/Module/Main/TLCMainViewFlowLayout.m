//
//  TLCMainViewFlowLayout.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import "TLCMainViewFlowLayout.h"
#import "UIWindow+TLCAdd.h"
#import "TLCDefine.h"

@interface TLCMainViewFlowLayout () 

@end

@implementation TLCMainViewFlowLayout


- (void)prepareLayout{
    
    [super prepareLayout];
}

- (CGFloat)pageWidth {
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
    CGFloat actualPage = 0.0;
    
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * self.pageWidth;
        actualPage = nextPage;
    } else {
        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
        actualPage = round(rawPageValue);
    }
    if (lround(actualPage) >= 1) {
        proposedContentOffset.x -= 4;
    } 
    
    return proposedContentOffset;
}

- (CGFloat)flickVelocity {
    return 0.3;
}

@end
