//
//  TLCMainCollectionViewCell.h
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import <UIKit/UIKit.h>
#import "TLPlanItem.h"

@class TLCMainCollectionViewCell;

@protocol TLCMainCollectionViewCellDeletate<NSObject>

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell didSelectTableViewRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell newScheduleAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell scrollViewDidScroll:(UIScrollView *)scrollView;

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell pullToRefreshAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell changePlanStateAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TLCMainCollectionViewCell : UICollectionViewCell

/**
 标识

 @return 标识
 */
+ (NSString *)identifier;

/**
 代理
 */
@property (nonatomic, weak) id<TLCMainCollectionViewCellDeletate> delegate;

/**
 列表视图
 */
@property (nonatomic, readonly, strong) UITableView *tableView;

/**
 CollectionViewCell所在的indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 根据数据，刷新页面

 @param data 数据数组
 @param indexPath 当前cell所在的位置
 @param title 头部标签
 */
- (void)updateCellWithData:(NSArray<TLPlanItem *> *)data
                 indexpath:(NSIndexPath *)indexPath
                     title:(NSString *)title;


- (void)updateCellWithData:(NSArray<TLPlanItem *> *)data;

- (NSArray<TLPlanItem *> *)currentDataSource;
 
@end
