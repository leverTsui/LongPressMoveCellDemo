####前言
最近参与了事务流程工具化组件的开发，其中有一个模块需要通过长按移动`Table View Cells`，来达到调整任务的需求，在此记录下开发过程中的实现思路。完成后的效果如下图所示：
  
![长按移动cell.gif](http://upload-images.jianshu.io/upload_images/117999-aca3146c0222d73a.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

####实现思路
- 添加手势
首先给 `collection view` 添加一个 `UILongGestureRecognizer`,在项目中一般使用懒加载的方式来对对象进行初始化：

```objectivec
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView =  [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[TLCMainCollectionViewCell class] forCellWithReuseIdentifier:[TLCMainCollectionViewCell identifier]];
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.bounces = YES;
        _collectionView.decelerationRate = 0;
        
        [_collectionView addGestureRecognizer:self.longPress];
    }
    return _collectionView;
}
```
```objectivec
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    }
    return _longPress;
}
```
在用户长按后，触犯长按事件，先获取到当前手势所在的`collection view`位置，再做后续的处理。
```objectivec
- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)sender {
    
    CGPoint location = [sender locationInView:sender.view];
    
    UIGestureRecognizerState state = sender.state;
    switch (state) {
            case UIGestureRecognizerStateBegan: {
                [self handleLongPressStateBeganWithLocation:location];
            }
            break;
            
            case UIGestureRecognizerStateChanged: {
            }
            break;
            
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                [self longGestureEndedOrCancelledWithLocation:location];
            }
            break;
            
        default:
            break;
    }
}
```
- 长按手势状态为开始
主要处理两个方面的事务，一为获取当前长按手势所对应的`Table View Cell`的镜像，将其添加到 `Collection View`上。二为一些初始状态的设置，后续在移动后网络请求出错及判断当前手势所处的`Table View`和上一次是否一致需要使用到。最后调用`startPageEdgeScroll `开启定时器。
```objectivec
- (void)handleLongPressStateBeganWithLocation:(CGPoint)location {
    
    TLCMainCollectionViewCell *selectedCollectionViewCell = [self currentTouchedCollectionCellWithLocation:location];
    
    NSIndexPath *touchIndexPath = [self longGestureBeganIndexPathForRowAtPoint:location atTableView:selectedCollectionViewCell.tableView];
   
    if (!selectedCollectionViewCell || !touchIndexPath) {
        return ;
    }
    self.selectedCollectionViewCellRow = [self.collectionView indexPathForCell:selectedCollectionViewCell].row;
    
    // 已完成的任务，不支持排序
    TLPlanItem *selectedItem = [self.viewModel itemAtIndex:self.selectedCollectionViewCellRow
                                              subItemIndex:touchIndexPath.section];
    if (!selectedItem || selectedItem.finish) {
        return;
    }
    selectedItem.isHidden = YES;
    
    self.snapshotView = [self snapshotViewWithTableView:selectedCollectionViewCell.tableView
                                            atIndexPath:touchIndexPath];
    [self.collectionView addSubview:self.snapshotView];
    
    self.selectedIndexPath = touchIndexPath;
    self.originalSelectedIndexPathSection = touchIndexPath.section;
    self.originalCollectionViewCellRow = self.selectedCollectionViewCellRow;
    self.previousPoint = CGPointZero;
    
    [self startPageEdgeScroll];
}
```
- 长按手势状态为改变
在`longPressGestureRecognized `方法中，可以发现，长按手势状态改变时，并未做任何的操作，主要原因是如果在此做`Table View Cells`的移动操作，如果数据超过一屏幕，无法自动将未在屏幕上的数据滚动显示出来。所以在长按手势状态为开始时，如果触摸点在`Table View Cell`上，开启定时器，来处理长按手势状态为改变时的情况。 
```objectivec
- (void)startPageEdgeScroll {
    self.edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(pageEdgeScrollEvent)];
    [self.edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
```
在定时器触发的事件中，处理两个方面的事情，移动cell和滚动`ScrollView`。
```objectivec
- (void)pageEdgeScrollEvent {
    [self longGestureChanged:self.longPress];
    
    CGFloat snapshotViewCenterOffsetX =  [self touchSnapshotViewCenterOffsetX];
    
    if (fabs(snapshotViewCenterOffsetX) > (TLCMainViewControllerFlowLayoutWidthOffset-20)) {
        //横向滚动
        [self handleScrollViewHorizontalScroll:self.collectionView viewCenterOffsetX:snapshotViewCenterOffsetX];
    } else {
        //垂直滚动
        [self handleScrollViewVerticalScroll:[self selectedCollectionViewCellTableView]];
    }
}
```
在长按手势触摸点位置改变时，处理对应`cell`的移除和插入动作。横向滚动和垂直滚动主要是根据不同情况设置对应的` Table View` 和 `Collection View`的内容偏移量。可以在文末的链接中查看源码。
```objectivec
- (void)longGestureChanged:(UILongPressGestureRecognizer *)sender {
    
    CGPoint currentPoint = [sender locationInView:sender.view];
    TLCMainCollectionViewCell *currentCollectionViewCell = [self currentTouchedCollectionCellWithLocation:currentPoint];
    if (!currentCollectionViewCell) {
        currentCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
    }
    
    TLCMainCollectionViewCell *lasetSelectedCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
    
    //判断targetTableView是否改变
    BOOL isTargetTableViewChanged = NO;
    if (self.selectedCollectionViewCellRow != currentCollectionViewCell.indexPath.row) {
        isTargetTableViewChanged = YES;
        self.selectedCollectionViewCellRow = currentCollectionViewCell.indexPath.row;
    }
    //获取到需要移动到的目标indexpath
    NSIndexPath *targetIndexPath = [self longGestureChangeIndexPathForRowAtPoint:currentPoint
                                                        collectionViewCell:currentCollectionViewCell];
    
    NSIndexPath *lastSelectedIndexPath = self.selectedIndexPath;
    
    TLCMainCollectionViewCell *selectedCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
    //判断跟上一次长按手势所处的Table View是否相同，如果相同，移动cell，
    //如果不同，删除上一次所定义的cell，插入到当前位置
    if (isTargetTableViewChanged) {
        if ([[self selectedCollectionViewCellTableView] numberOfSections]>targetIndexPath.section) {
            [[self selectedCollectionViewCellTableView] scrollToRowAtIndexPath:targetIndexPath
                                                              atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
        
        TLPlanItem *moveItem = [self.viewModel itemAtIndex:lasetSelectedCollectionViewCell.indexPath.row
                                              subItemIndex:lastSelectedIndexPath.section];
        [self.viewModel removeObject:moveItem
                           itemIndex:lasetSelectedCollectionViewCell.indexPath.row];
        [self.viewModel insertItem:moveItem
                             index:self.selectedCollectionViewCellRow
                      subItemIndex:targetIndexPath.section];

        [lasetSelectedCollectionViewCell updateCellWithData:[self planItemsAtIndex:lasetSelectedCollectionViewCell.indexPath.row]];
        [lasetSelectedCollectionViewCell.tableView deleteSections:[NSIndexSet indexSetWithIndex:lastSelectedIndexPath.section]
                                                 withRowAnimation:UITableViewRowAnimationNone];

        [selectedCollectionViewCell updateCellWithData:[self planItemsAtIndex:self.selectedCollectionViewCellRow]];
        [selectedCollectionViewCell.tableView insertSections:[NSIndexSet indexSetWithIndex:targetIndexPath.section]
                                            withRowAnimation:UITableViewRowAnimationNone];
    } else {
        BOOL isSameSection = lastSelectedIndexPath.section == targetIndexPath.section;
        UITableViewCell *targetCell = [self tableView:[self selectedCollectionViewCellTableView]
                                selectedCellAtSection:targetIndexPath.section];
        if (isSameSection || !targetCell ) {
            [self modifySnapshotViewFrameWithTouchPoint:currentPoint];
            return;
        }
        
        TLPlanItem *item = [self.viewModel itemAtIndex:self.selectedCollectionViewCellRow
                                          subItemIndex:lastSelectedIndexPath.section];
        [self.viewModel removeObject:item
                           itemIndex:self.selectedCollectionViewCellRow];
        [self.viewModel insertItem:item
                             index:self.selectedCollectionViewCellRow
                      subItemIndex:targetIndexPath.section];
        
        [selectedCollectionViewCell updateCellWithData:[self planItemsAtIndex:self.selectedCollectionViewCellRow]];
        [selectedCollectionViewCell.tableView moveSection:lastSelectedIndexPath.section
                                                toSection:targetIndexPath.section];
    }
    
    self.selectedIndexPath = targetIndexPath;
    //改变长按cell镜像的位置
    [self modifySnapshotViewFrameWithTouchPoint:currentPoint];
}
```
- 长按手势状态为取消或结束
取消计时器，设置`Collection View`的偏移量，让其`Collection View Cell`位于屏幕的中心，发送网络请求，去调整任务的排序，同时将镜像视图隐藏，并将其所对应的`Table View Cell`显示出来。
```objectivec
- (void)longGestureEndedOrCancelledWithLocation:(CGPoint)location {
    
    [self stopEdgeScrollTimer];
    
    CGPoint contentOffset = [self.flowLayout targetContentOffsetForProposedContentOffset:self.collectionView.contentOffset
                                                                   withScrollingVelocity:CGPointZero];
    [self.collectionView setContentOffset:contentOffset animated:YES];
    
    UITableViewCell *targetCell = [[self selectedCollectionViewCellTableView] cellForRowAtIndexPath:self.selectedIndexPath];
    
    if ([self canAdjustPlanRanking]) {
        [self adjustPlanRanking];
    }
    TLPlanItem *slectedItem = [self.viewModel itemAtIndex:self.selectedCollectionViewCellRow subItemIndex:self.selectedIndexPath.section];
    [UIView animateWithDuration:0.25 animations:^{
        self.snapshotView.transform = CGAffineTransformIdentity;
        self.snapshotView.frame = [self snapshotViewFrameWithCell:targetCell];
        
    } completion:^(BOOL finished) {
        targetCell.hidden = NO;
        slectedItem.isHidden = NO;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    }];
}
``` 
- 数据的处理
在移动和插入`Table View Cell`时，需要将其所对应的数据做响应的改变，数据相关的操作均放在`TLCMainViewModel`对象中。
```objectivec
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
```
####代码完善
`2018年2月1号`
在iPhone系统版本为`iOS8.x`和`iOS9.x`时，会出现`以后要做`界面不会回弹的情况。如下图所示：
![bug1.png](http://upload-images.jianshu.io/upload_images/117999-dfea45068404f800.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
经排查，是在`UICollectionViewFlowLayout`类中的`- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity`,计算得出的`proposedContentOffset`有偏差，修改后如下所示：
```objectivec
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat rawPageValue = self.collectionView.contentOffset.x / [self tlc_pageWidth];
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > [self tlc_flickVelocity];
    CGFloat actualPage = 0.0;
    
    if (pannedLessThanAPage && flicked) {
        proposedContentOffset.x = nextPage * [self tlc_pageWidth];
        actualPage = nextPage;
    } else {
        proposedContentOffset.x = round(rawPageValue) * [self tlc_pageWidth];
        actualPage = round(rawPageValue);
    } 
    if (lround(actualPage) >= 1) {
        proposedContentOffset.x -= 4.5;
    } 
    //下面为添加的代码
    if (lround(actualPage) >= 2) {
        proposedContentOffset.x = self.collectionView.contentSize.width - TLCScreenWidth;
    }
    
    return proposedContentOffset;
}
```
####总结
除了上述`Table View Cell`移动的操作，在项目中还处理了创建事务和事务详情相关的业务。在整个过程中，比较棘手的还是`Table View Cell`的移动，在开发过程中，有时数据的移动和`Table View Cell`的移动未对应上，造成`Table View Cell`布局错乱，排查了很久。在项目开发过程中，还是需要仔细去分析需求。

文章所对应的`Demo`请点[这里](https://github.com/hua16/LongPressMoveCellDemo)
本文已经同步到我的个人技术博客： [传送门](http://levertsui.com/2018/01/19/iOS%E9%95%BF%E6%8C%89%E7%A7%BB%E5%8A%A8Table%20View%20Cells/) ，欢迎常来^^。
参考的文章链接如下
[利用长按手势移动 Table View Cells](http://beyondvincent.com/2014/03/26/2014-03-26-cookbook-moving-table-view-cells-with-a-long-press-gesture/)
