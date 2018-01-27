//
//  TCLMainViewModel.h
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLCDefine.h"
#import "TLPlanItemReq.h"
#import "TLPlanItem.h"


@class TLCBaseViewController;
@class TLPlanCategoryModel;

@interface TLCMainViewModel : NSObject 

/**
 今日要做、下一步要做和以后要做
 */
@property (nonatomic, readonly, strong) NSArray <NSString *> *titleArray; 

/**
 获取计划列表
 
 @param completion  TLTodoModel
 */
- (void)obtainTotalPlanListWithTypeCompletion:(TLSDKCompletionBlk)completion;

/**
 添加计划

 @param requestItem requestItem
 @param completion 完成回调
 */
- (void)addPlanWithReq:(TLPlanItemReq *)requestItem
           atIndexPath:(NSIndexPath *)indexPath
            completion:(TLSDKCompletionBlk)completion;

/**
 返回显示的collectionViewCell的个数

 @return 数据的个数
 */
- (NSInteger)numberOfItems;

/**
 根据type获取对应的数据

 @param index 位置
 @return 此计划所对应的数据
 */
- (NSMutableArray<TLPlanItem *> *)planItemsAtIndex:(NSInteger)index;

/**
 删除某个计划
 
 @param itemIndex 单项数据在数组中的位置，如今日计划中的数据，itemIndex为0
 @param subItemIndex  单项数据数组中所在的位置
 @param completion 完成回调
 */
- (void)deletePlanAtItemIndex:(NSInteger)itemIndex
                 subItemIndex:(NSInteger)subItemIndex
                   completion:(dispatch_block_t)completion;


/**
 修改计划状态：完成与非完成
 
 @param itemIndex 单项数据在数组中的位置，如今日计划中的数据，itemIndex为0
 @param subItemIndex  单项数据数组中所在的位置
 @param completion 完成回调
 */
- (void)modiflyPlanStateAtItemIndex:(NSInteger)itemIndex
                       subItemIndex:(NSInteger)subItemIndex
                         completion:(TLSDKCompletionBlk)completion;


/**
 修改计划的title和重点标记状态

 @param itemIndex 单项数据在数组中的位置，如今日计划中的数据，itemIndex为0
 @param subItemIndex 单项数据数组中所在的位置
 @param targetItem 目标对象
 @param completion 完成回调
 */
- (void)modiflyItemAtIndex:(NSInteger)itemIndex
              subItemIndex:(NSInteger)subItemIndex
                targetItem:(TLPlanItem *)targetItem
                completion:(dispatch_block_t)completion;


/**
 移除数据

 @param item item
 @param itemIndex 单项数据在数组中的位置
 */
- (void)removeObject:(TLPlanItem *)item
           itemIndex:(NSInteger)itemIndex;

/**
 插入数据
 
 @param item 插入的对象模型
 @param itemIndex 单项数据在数组中的位置，如今日计划中的数据，itemIndex为0
 @param subItemIndex 单项数据数组中所在的位置
 */
- (void)insertItem:(TLPlanItem *)item
             index:(NSInteger)itemIndex
      subItemIndex:(NSInteger)subItemIndex;

/**
 获取数据

 @param itemIndex 一级index
 @param subItemIndex 二级index
 @return 数据模型
 */
- (TLPlanItem *)itemAtIndex:(NSInteger)itemIndex
               subItemIndex:(NSInteger)subItemIndex; 

/**
 重置数据
 */
- (void)reset;

/**
 保存长按开始时的数据
 */
- (void)storePressBeginState;

@end
