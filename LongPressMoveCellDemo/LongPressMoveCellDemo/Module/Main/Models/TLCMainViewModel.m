//
//  TCLMainViewModel.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import "TLCMainViewModel.h"
#import "TLCDefine.h"
#import "TLPlanCategoryModel.h"

@interface TLCMainViewModel  () 

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSArray <NSString *> *titleArray;

@property (nonatomic, strong) TLPlanCategoryModel *model;

@end

@implementation TLCMainViewModel

#pragma mark - public

- (void)obtainTotalPlanListWithTypeCompletion:(TLSDKCompletionBlk)completion {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSDictionary *dataDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    TLPlanCategoryModel *model = [MTLJSONAdapter modelOfClass:[TLPlanCategoryModel class] fromJSONDictionary:dataDic error:nil];
    self.model = model;
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:[model.today mutableCopy]];
    [self.dataArray addObject:[model.next mutableCopy]];
    [self.dataArray addObject:[model.future mutableCopy]];
    
    if (completion) {
        completion(self.model, nil);
    }
}

- (void)reset {
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:[self.model.today mutableCopy]];
    [self.dataArray addObject:[self.model.next mutableCopy]];
    [self.dataArray addObject:[self.model.future mutableCopy]];
}

- (void)storePressBeginState {
    
    self.model.today = [MUPArrayObjectAtIndex(self.dataArray, 0) mutableCopy];
    self.model.next = [MUPArrayObjectAtIndex(self.dataArray, 1) mutableCopy];
    self.model.future = [MUPArrayObjectAtIndex(self.dataArray, 2) mutableCopy];
}

- (void)addPlanWithReq:(TLPlanItemReq *)requestItem
           atIndexPath:(NSIndexPath *)indexPath
            completion:(TLSDKCompletionBlk)completion {
    
    // Demo使用，实际需要发送网络请求
    TLPlanItem *item = [[TLPlanItem alloc] init];
    item.title = requestItem.title;
    item.type = requestItem.type;
    item.important = requestItem.important;
    item.idStr = [NSUUID UUID].UUIDString;
    NSMutableArray<TLPlanItem *> *items = [self planItemsAtIndex:indexPath.row];
    [items insertObject:item atIndex:0];
    if (completion) {
        completion(item,nil);
    } 
}

- (NSInteger)numberOfItems {
    
    return self.dataArray.count;
}

- (NSMutableArray<TLPlanItem *> *)planItemsAtIndex:(NSInteger)index {
    
   return MUPArrayObjectAtIndex(self.dataArray, index);
}  

- (void)deletePlanAtItemIndex:(NSInteger)itemIndex
                 subItemIndex:(NSInteger)subItemIndex
                   completion:(dispatch_block_t)completion {
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    [items removeObjectAtIndex:subItemIndex];
    if (completion) {
        completion();
    }
}

- (void)modiflyPlanStateAtItemIndex:(NSInteger)itemIndex
                       subItemIndex:(NSInteger)subItemIndex
                         completion:(TLSDKCompletionBlk)completion {
    
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    TLPlanItem *item = MUPArrayObjectAtIndex(items, subItemIndex);
    item.finish = !item.finish;
    [self adjustItemSort:item atArray:items];
    
    if (completion) {
        completion(nil,nil);
    }
}

- (void)modiflyItemAtIndex:(NSInteger)itemIndex
              subItemIndex:(NSInteger)subItemIndex
                targetItem:(TLPlanItem *)targetItem
                completion:(dispatch_block_t)completion {
    
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    TLPlanItem *item = MUPArrayObjectAtIndex(items, subItemIndex);
    if (item) {
        item.title = targetItem.title;
        item.important = targetItem.important;
        BOOL isFinishStateChange = [self isChangeWithOriginalState:item.finish targetFinish:targetItem.finish];
        if (isFinishStateChange) {
            item.finish = targetItem.finish;
            [self adjustItemSort:item atArray:items];
        }
    }
    if (completion) {
        completion(); 
    }
}

- (void)removeObject:(TLPlanItem *)item
           itemIndex:(NSInteger)itemIndex  {
    
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    [items removeObject:item]; 
}


- (void)insertItem:(TLPlanItem *)item
             index:(NSInteger)itemIndex
      subItemIndex:(NSInteger)subItemIndex { 
    
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    [items insertObject:item atIndex:subItemIndex];
}

- (TLPlanItem *)itemAtIndex:(NSInteger)itemIndex
               subItemIndex:(NSInteger)subItemIndex {
    
    NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:itemIndex];
    return MUPArrayObjectAtIndex(items, subItemIndex);
} 

- (void)adjustItemSort:(TLPlanItem *)item atArray:(NSMutableArray<TLPlanItem *> *)items {
    
    [items removeObject:item];
    if (item.finish) {
        [items addObject:item];
    } else {
        [items insertObject:item atIndex:0];
    }
}
 
#pragma mark - private

- (BOOL)isChangeWithOriginalState:(BOOL)isOriginalFinish
                     targetFinish:(BOOL)isTargetFinish {
    
    return (!isOriginalFinish && isTargetFinish)
    || (isOriginalFinish && !isTargetFinish);
}

#pragma mark - getter & setter

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array]; 
    }
    return _dataArray;
}

- (NSArray<NSString *> *)titleArray {
    if (!_titleArray) {
        _titleArray = @[TLCLocalizedString(@"TLC_Main_Today_To_Do"),
                        TLCLocalizedString(@"TLC_Main_Next_Step_To_Do"),
                        TLCLocalizedString(@"TLC_Main_Later_To_Do")];
    }
    return _titleArray;
}

@end
