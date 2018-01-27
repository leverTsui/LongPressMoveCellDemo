//
//  TCLProjectCell.h
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import <UIKit/UIKit.h>
#import "TLPlanItem.h"


@class TLCProjectCell;
@protocol TLCProjectCellDelegete<NSObject>

- (void)tlc_projectCell:(TLCProjectCell *)cell changePlanStateAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLCProjectCell : UITableViewCell

@property (nonatomic, weak) id<TLCProjectCellDelegete> delegate;

+ (NSString *)identifier;
    

/**
 根据获取到的数据，计算cell的高度
 
 @param model 数据model
 @param itemWidth collection cell的宽度
 @return cell的高度
 */
+ (CGFloat)calculateCellHeightWithModel:(TLPlanItem *)model itemWidth:(CGFloat)itemWidth;


/**
 填充数据
 
 @param model model
 */
- (void)updateWithModel:(TLPlanItem *)model indexPath:(NSIndexPath *)indexPath;

@end
