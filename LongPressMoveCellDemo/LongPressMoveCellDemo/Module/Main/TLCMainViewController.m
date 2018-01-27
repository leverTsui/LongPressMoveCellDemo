//
//  TLCMainViewController.m
//  transaction_list_ios
//
//  Created by Chris on 2017/12/19.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "TLCMainViewController.h"
#import <Masonry/Masonry.h>
#import "TLCMainCollectionViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
 
#import "TLCDefine.h"
#import "TLCGlobalCommon.h"
#import "TLCMainViewFlowLayout.h"
#import "TLCMainViewModel.h"
#import "TLCMainInputView.h"

#import "UIView+TLCSnapshot.h"
#import "UIWindow+TLCAdd.h"
#import "UIColor+TLCAdd.h"

#import "TLCProjectCell.h"
#import "TLCDetailViewController.h"

static const CGFloat TLCMainViewControllerHeaderLableHeight = 35;
static const CGFloat TLCMainViewControllerTableViewMarginBottom = 27;
static const CGFloat TLCMainViewControllerFlowLayoutWidthOffset = 45;

@interface TLCMainViewController ()<UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    TLCMainCollectionViewCellDeletate,
                                    TLCMainInputViewDeletate>

/**
 数据层model
 */
@property (nonatomic, strong) TLCMainViewModel *viewModel;

/**
 菜单导航栏按钮
 */
@property (nonatomic, strong)  UIBarButtonItem *menuItem;

/**
 提醒导航栏按钮
 */
@property (nonatomic, strong) UIBarButtonItem *remindSettingItem;

/**
 头部提示标签
 */
@property (nonatomic, strong) UILabel *headerLable;

/**
 主视图，其余的视图均添加在此视图上
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 底部视图
 */
@property (nonatomic, strong) UIView *bottomView;

/**
 布局layout
 */
@property (nonatomic, strong) TLCMainViewFlowLayout *flowLayout;

/**
 当前长按选中cell截图
 */
@property (nonatomic, strong) UIView *snapshotView;

/**
 当前长按选中cell所在TableView上的位置
 */
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

/**
 长按开始时选中cell所在TableView上的位置
 */
@property (nonatomic, assign) NSInteger originalSelectedIndexPathSection;

/**
 长按开始时选中cell所在TableView上的位置
 */
@property (nonatomic, assign) NSInteger originalCollectionViewCellRow;

/**
 当前长按选中cell所在的CollectionViewCell的行数
 */
@property (nonatomic, assign) NSInteger selectedCollectionViewCellRow;

/**
 *  边缘滚动触发范围，默认150
 */
@property (nonatomic, assign) CGFloat edgeScrollRange;

/**
 定时器
 */
@property (nonatomic, strong) CADisplayLink *edgeScrollTimer;

/**
 长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

/**
 长按时上一次手指所在的位置
 */
@property (nonatomic, assign) CGPoint previousPoint;

/**
 输入框
 */
@property (nonatomic, strong) TLCMainInputView *inputProjectView; 

@end

@implementation TLCMainViewController

#pragma mark - life cycle

- (void)awakeFromNib {
    [super awakeFromNib];
    _edgeScrollRange = 150.0f;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _edgeScrollRange = 150.0f;
    }
    return self;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configurePageView];
    [self addPageSubviews];
    [self layoutPageSubviews];
    [self addObserver];
    [self fetchPlanListData];
}

- (void)dealloc {
    
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self handleSingleTabBarViewControllers];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - UI & autolayout

- (void)configurePageView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = TLCLocalizedString(@"TLC_Main_All_Everyday_Project");
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.rightBarButtonItems = @[self.menuItem,self.remindSettingItem];
}

- (void)addPageSubviews {
    
    [self.view addSubview:self.headerLable];
    [self.view addSubview:self.collectionView];
}

- (void)layoutPageSubviews {
    
    [self.headerLable mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
        make.height.mas_equalTo(TLCMainViewControllerHeaderLableHeight);
        make.leading.equalTo(self.view).offset(18);
        make.trailing.equalTo(self.view).offset(-18);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view);
        }
        make.top.equalTo(self.headerLable.mas_bottom);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
}

#pragma mark - keyboard observer

- (void)addObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyBoardWillChageFrame:)
                                                name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveNotify:)
                                                 name:TLCNotificationUpdatePlan object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveNotify:)
                                                 name:TLCNotificationDeletePlan object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [self.inputProjectView resetText];
    self.inputProjectView.frame = CGRectMake(0, TLCScreenHeight, TLCScreenWidth, 88);
}

- (void)keyBoardWillChageFrame:(NSNotification *)notification {
    NSDictionary * infoDict = [notification userInfo];
    
    CGRect beginFrame = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endFrame = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat offset_y = endFrame.origin.y - beginFrame.origin.y;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGFloat endHeight = TLCScreenHeight - [keyWindow TLCNavigationBarHeight];
    
    CGFloat projectInputViewBottom = 0;
    if (offset_y<0) { //弹出键盘
        if (endFrame.origin.y < endHeight) {
            projectInputViewBottom = endHeight - endFrame.size.height;
        } else {//避免一些 键盘在屏幕下方浮动的现象
            projectInputViewBottom = endHeight;
        }
    }else{//键盘下移或消失
        if (endFrame.origin.y >= endHeight) {//键盘完全消失
            projectInputViewBottom = endHeight;
        } else {//键盘只是变矮了一点
            projectInputViewBottom = endHeight - endFrame.size.height;
        }
    }
    
    CGFloat duration = [[infoDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = CGRectGetHeight(self.inputProjectView.frame);
    
    [UIView animateWithDuration:duration animations:^{
        self.inputProjectView.frame = CGRectMake(0, projectInputViewBottom-height, TLCScreenWidth, height);
    }];
}

#pragma mark - network request

- (void)fetchPlanListData {
    @weakify(self)
    [self.viewModel obtainTotalPlanListWithTypeCompletion:^(id resData, NSError *err) {
        @strongify(self)
        [self.collectionView reloadData];
    }];
}

- (void)adjustPlanRanking {
    //TO DO发送网络请求，调整位置
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TLCMainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[TLCMainCollectionViewCell identifier] forIndexPath:indexPath];
    cell.delegate = self;
   
    [cell updateCellWithData: [self planItemsAtIndex:indexPath.row]
                   indexpath:indexPath
                       title:MUPArrayObjectAtIndex(self.viewModel.titleArray, indexPath.row)];
    return cell;
}

#pragma mark - TLCMainCollectionViewCellDeletate

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell didSelectTableViewRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TLPlanItem *model = [self.viewModel itemAtIndex:collectionViewCell.indexPath.row subItemIndex:indexPath.section];
    TLCDetailViewController *detailViewController = [[TLCDetailViewController alloc] initWithModel:model];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell newScheduleAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.inputProjectView.superview) {
        [self.view addSubview:self.inputProjectView];
    }
    self.inputProjectView.frame = CGRectMake(0, TLCScreenHeight, TLCScreenWidth, 88);
    self.inputProjectView.indexPath = indexPath;
    [self.inputProjectView textViewBecomeFirstResponder];
}

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell pullToRefreshAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel obtainTotalPlanListWithTypeCompletion:^(id resData, NSError *err) {
        [self.collectionView reloadData];
    }];
}

- (void)collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell changePlanStateAtIndexPath:(NSIndexPath *)indexPath {
    
    MBProgressHUD *progressHUD = [MBProgressHUD HUDForView:self.view];
    progressHUD.graceTime = 0.3;
    [progressHUD showAnimated:YES];
    
    @weakify(self)
    [self.viewModel modiflyPlanStateAtItemIndex:collectionViewCell.indexPath.row subItemIndex:indexPath.section completion:^(id resData, NSError *err) {
        @strongify(self)
       [progressHUD hideAnimated:YES];
        NSMutableArray<TLPlanItem *> *items =  [self planItemsAtIndex:collectionViewCell.indexPath.row];
        [collectionViewCell updateCellWithData:items];
        [collectionViewCell.tableView reloadData];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
}

#pragma mark - event response 

- (void)onReceiveNotify:(NSNotification *)notify{
    
    [self handleNotifyName:notify.name plan:notify.object];
}

- (void)menuButtonClicked:(UIButton *)sender {
    
}

- (void)remindSettingClicked:(UIButton *)sender {
     
}

//长按cell事件
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

#pragma mark - long press state

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

- (void)longGestureChanged:(UILongPressGestureRecognizer *)sender {
    
    CGPoint currentPoint = [sender locationInView:sender.view];
    TLCMainCollectionViewCell *currentCollectionViewCell = [self currentTouchedCollectionCellWithLocation:currentPoint];
    if (!currentCollectionViewCell) {
        currentCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
    }
    
    TLCMainCollectionViewCell *lasetSelectedCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
    
    BOOL isTargetTableViewChanged = NO;
    if (self.selectedCollectionViewCellRow != currentCollectionViewCell.indexPath.row) {
        isTargetTableViewChanged = YES;
        self.selectedCollectionViewCellRow = currentCollectionViewCell.indexPath.row;
    }
    
    NSIndexPath *targetIndexPath = [self longGestureChangeIndexPathForRowAtPoint:currentPoint
                                                        collectionViewCell:currentCollectionViewCell];
    
    NSIndexPath *lastSelectedIndexPath = self.selectedIndexPath;
    
    TLCMainCollectionViewCell *selectedCollectionViewCell = [self collectionViewCellAtRow:self.selectedCollectionViewCellRow];
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
                      subItemIndex:targetIndexPath.section
                                       ];
        
        [selectedCollectionViewCell updateCellWithData:[self planItemsAtIndex:self.selectedCollectionViewCellRow]];
        [selectedCollectionViewCell.tableView moveSection:lastSelectedIndexPath.section
                                                toSection:targetIndexPath.section];
    }
    
    self.selectedIndexPath = targetIndexPath;
    
    [self modifySnapshotViewFrameWithTouchPoint:currentPoint];
}

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

#pragma mark - TLCMainInputViewDeletate

- (void)mainInputView:(TLCMainInputView *)view creatProjectAtIndexPath:(NSIndexPath *)indexPath {
    
    TLPlanItemReq *itemReq = [[TLPlanItemReq alloc] init];
    itemReq.important = NO; 
    itemReq.title = [view inputText];
    itemReq.type = (TLSDKPlanType)(indexPath.row+1);
    
    @weakify(self)
    [self.viewModel addPlanWithReq:itemReq atIndexPath:indexPath
                        completion:^(id resData, NSError *err) {
        @strongify(self)
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }];
}

#pragma mark - page scroll

- (void)startPageEdgeScroll {
    self.edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(pageEdgeScrollEvent)];
    [self.edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

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

- (void)stopEdgeScrollTimer {
    if (self.edgeScrollTimer) {
        [self.edgeScrollTimer invalidate];
        self.edgeScrollTimer = nil;
    }
}

- (void)handleScrollViewVerticalScroll:(UIScrollView *)scrollView {
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    CGFloat tableViewHeight = CGRectGetHeight(scrollView.bounds);
    
    //最小偏移量
    CGFloat minOffsetY = contentOffsetY + self.edgeScrollRange;
    
    //最大偏移量
    CGFloat maxOffsetY = contentOffsetY + tableViewHeight - self.edgeScrollRange;
    
    //转换坐标
    CGPoint touchPoint = [self.collectionView convertPoint:self.snapshotView.center toView:scrollView];
    
    if (touchPoint.y < self.edgeScrollRange) {
        //在顶部的滚动范围内
        //已滚动到最顶部，直接返回
        if (contentOffsetY < 1){
            return;
        }
        [self handleTableView:scrollView isScrollToTop:YES];
        return;
    }
    
    if (touchPoint.y > (scrollView.contentSize.height-self.edgeScrollRange)) {
        //在底部的滚动范围内
        if (contentOffsetY > (scrollView.contentSize.height-tableViewHeight+CGRectGetHeight(self.snapshotView.frame))) {
            return;
        }
        
        [self handleTableView:scrollView isScrollToTop:NO];
        return;
    }
    
    BOOL isNeedScrollToTop = touchPoint.y < minOffsetY;
    BOOL isNeedScrollToBottom = touchPoint.y > maxOffsetY;
    
    if (isNeedScrollToTop) {
        //tableView往上滚动
        [self handleTableView:scrollView isScrollToTop:YES];
        
    } else if (isNeedScrollToBottom) {
        //tableView往下滚动
        [self handleTableView:scrollView isScrollToTop:NO];
    } else { 
    }
}

- (void)handleScrollViewHorizontalScroll:(UIScrollView *)scrollView
                       viewCenterOffsetX:(CGFloat)viewCenterOffsetX {
    
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.bounds);

    if (viewCenterOffsetX > 0) {
        //向右边滚动
        if (contentOffsetX >= (scrollView.contentSize.width-scrollViewWidth)) {
            return;
        }
        
    } else {
        //向左边滚动
        if (contentOffsetX < 1){
            return;
        }
    }
    CGFloat scrollViewContentOffsetX = scrollView.contentOffset.x + [self scrollDistanceWithOffsetX:viewCenterOffsetX];
    [scrollView setContentOffset:CGPointMake(scrollViewContentOffsetX, scrollView.contentOffset.y) animated:NO];
    return;
}


- (CGFloat)scrollDistanceWithOffsetX:(CGFloat)offsetX {
    
    CGFloat maxMoveDistance = 20;
    CGFloat maxDistance = ((CGRectGetWidth(self.collectionView.frame)-20)/2);
    return  maxMoveDistance * (offsetX / maxDistance);
}


- (void)handleTableView:(UIScrollView *)tableView isScrollToTop:(BOOL)isScrollToTop {
    
    CGFloat distance = 2.0;
    if (isScrollToTop) {
        distance = -distance;
    } else {
        NSIndexPath *indexPath = [[self selectedCollectionViewCellTableView].indexPathsForVisibleRows lastObject];
        TLPlanItem *item = [self.viewModel itemAtIndex:self.selectedCollectionViewCellRow subItemIndex:indexPath.section];
        if (item.finish) {
            return;
        }
    }
    [tableView setContentOffset:CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y + distance) animated:NO];
}

#pragma mark - private

- (void)handleNotifyName:(NSString *)notifyName plan:(TLPlanItem *)item{
    
    if (![notifyName isEqualToString:TLCNotificationUpdatePlan]
        && ![notifyName isEqualToString:TLCNotificationDeletePlan]) {
        return ;
    }
    
    if (!item) {
        return ;
    }
    __block NSInteger itemIndex = -1;
    __block NSInteger subItemIndex = -1;
    for (NSInteger i = 0; i< [self.viewModel numberOfItems]; i++) {
        NSArray<TLPlanItem *> *currentItems = [self planItemsAtIndex:i];
        [currentItems enumerateObjectsUsingBlock:^(TLPlanItem * _Nonnull subItem, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subItem.idStr isEqualToString:item.idStr]) {
                *stop = YES;
                itemIndex = i;
                subItemIndex = idx;
            }
        }];
        if (itemIndex>=0) {
            break;
        }
    }
    
    if ([notifyName isEqualToString:TLCNotificationUpdatePlan]) {
        @weakify(self)
        [self.viewModel modiflyItemAtIndex:itemIndex subItemIndex:subItemIndex targetItem:item completion:^{
            @strongify(self)
            [self.collectionView reloadData];
        }];
    } else {
        @weakify(self)
        [self.viewModel deletePlanAtItemIndex:itemIndex subItemIndex:subItemIndex completion:^{
            @strongify(self)
            [self.collectionView reloadData]; 
        }];
    }
}

//根据手势坐标，获取当前手势所在的TLCMainCollectionViewCell
- (TLCMainCollectionViewCell *)currentTouchedCollectionCellWithLocation:(CGPoint)location {
    
    TLCMainCollectionViewCell *currentCollectionViewCell = nil;
    for (TLCMainCollectionViewCell *collectionViewCell in self.collectionView.visibleCells) {
        
        CGRect frame = [collectionViewCell convertRect:collectionViewCell.tableView.frame
                                                toView:self.collectionView];
        if (location.x> CGRectGetMinX(frame) && location.x < CGRectGetMaxX(frame)) {
            currentCollectionViewCell = collectionViewCell;
            break;
        }
    }
    return currentCollectionViewCell;
}

- (UIView *)currentSnapshotViewWithCell:(UITableViewCell *)cell {
    
    UIView *snapshotView = [cell snapshotView];
    
    snapshotView.layer.shadowColor = [UIColor grayColor].CGColor;
    snapshotView.layer.masksToBounds = NO;
    snapshotView.layer.cornerRadius = 0;
    snapshotView.layer.shadowOffset = CGSizeMake(-5, 0);
    snapshotView.layer.shadowOpacity = 0.4;
    snapshotView.layer.shadowRadius = 5;
    
    snapshotView.frame = [self snapshotViewFrameWithCell:cell];
    snapshotView.transform = CGAffineTransformMakeRotation(M_PI_2/32);
    
    return snapshotView;
}

- (CGRect)snapshotViewFrameWithCell:(UITableViewCell *)cell {
    
    return [[self selectedCollectionViewCellTableView] convertRect:cell.frame
                                                            toView:self.collectionView];
}

- (void)handleSingleTabBarViewControllers {
    
    if ([self.tabBarController.viewControllers count] == 1) {
        //单个tab时隐藏tabbar
        CGFloat tabBarX = self.tabBarController.tabBar.frame.origin.x;
        CGFloat tabBarWidth = self.tabBarController.tabBar.frame.size.width;
        CGFloat tabBarHeight = self.tabBarController.tabBarController.tabBar.frame.size.height;
        self.tabBarController.tabBar.frame = CGRectMake(tabBarX,CGRectGetHeight(self.view.frame),tabBarWidth,tabBarHeight);
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (CGFloat)touchSnapshotViewCenterOffsetX {
    
    CGPoint touchSnapshotViewCenter = [self.collectionView convertPoint:self.snapshotView.center
                                                                 toView:self.view];
    CGPoint viewCenter = self.view.center;
    return touchSnapshotViewCenter.x - viewCenter.x;
}

//修改截屏cell的frame
- (void)modifySnapshotViewFrameWithTouchPoint:(CGPoint)touchPoint {
    
    if (!CGPointEqualToPoint(self.previousPoint,CGPointZero)) {
        CGPoint newCenter = self.snapshotView.center;
        newCenter.x += (touchPoint.x-self.previousPoint.x);
        newCenter.y += (touchPoint.y-self.previousPoint.y);
        self.snapshotView.center = newCenter;
    }
    self.previousPoint = touchPoint;
}

//处理选中的cell快照
- (UIView *)snapshotViewWithTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIView *snapshotView = [self currentSnapshotViewWithCell:selectedCell];
    selectedCell.hidden = YES;
    return snapshotView;
}

//获取长按开始时cell在tableview上的位置
- (NSIndexPath *)longGestureBeganIndexPathForRowAtPoint:(CGPoint)touchPoint atTableView:(UITableView *)tableView {
    
    CGPoint point = [self.collectionView convertPoint:touchPoint
                                               toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:point];
    return indexPath;
}

//获取长按位置改变时cell在tableview上的位置
- (NSIndexPath *)longGestureChangeIndexPathForRowAtPoint:(CGPoint)touchPoint
                                      collectionViewCell:(TLCMainCollectionViewCell *)collectionViewCell {
    
    CGPoint point = [self.collectionView convertPoint:touchPoint
                                               toView:collectionViewCell.tableView];
    __block NSIndexPath *indexPath = [collectionViewCell.tableView indexPathForRowAtPoint:point];
    
    if (!indexPath) {
        NSInteger numberOfSections = [collectionViewCell.tableView numberOfSections];
        if (numberOfSections == 0) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else {
            NSIndexPath *maxVisibleIndexPath = [collectionViewCell.tableView.indexPathsForVisibleRows lastObject];
            CGRect maxSectionRect = [collectionViewCell.tableView rectForRowAtIndexPath:maxVisibleIndexPath];
            if (point.y > CGRectGetMaxY(maxSectionRect)) {
                indexPath = maxVisibleIndexPath;
            } else {
                BOOL isInVisibleCell = NO;
                for (NSIndexPath *visibleIndexPath  in collectionViewCell.tableView.indexPathsForVisibleRows) {
                    CGRect sectionRect = [collectionViewCell.tableView rectForSection:visibleIndexPath.section];
                    if (point.y>CGRectGetMinY(sectionRect) && point.y<CGRectGetMaxY(sectionRect)) {
                        indexPath = visibleIndexPath;
                        isInVisibleCell = YES;
                    }
                }
                if (!isInVisibleCell) {
                    indexPath = [collectionViewCell.tableView.indexPathsForVisibleRows firstObject]; 
                }
            }
        }
    }
    
    NSMutableArray<TLPlanItem *> *currentItems = [self planItemsAtIndex:collectionViewCell.indexPath.row];
    
    if (indexPath.section>0) {
        //取最后一个未完成的计划
        [currentItems enumerateObjectsUsingBlock:^(TLPlanItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.finish) {
                *stop = YES;
                if (indexPath.section<idx) {
                    return ;
                }
                if (idx==0) {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                } else {
                    indexPath = [NSIndexPath indexPathForRow:0 inSection:idx-1];
                }
            }
        }];
    }
    
    return indexPath;
}

- (BOOL)canAdjustPlanRanking {
    
    if (!self.selectedIndexPath) {
        return NO;
    }
    if (self.originalCollectionViewCellRow == self.selectedCollectionViewCellRow
        && self.selectedIndexPath.section == self.originalSelectedIndexPathSection) {
        return NO;
    }
    return YES;
}

- (NSMutableArray<TLPlanItem *> *)planItemsAtIndex:(NSUInteger)index {
    
    return [self.viewModel planItemsAtIndex:index];
}

- (UITableView *)selectedCollectionViewCellTableView {
    return [self collectionViewCellAtRow:self.selectedCollectionViewCellRow].tableView;
}

- (TLCMainCollectionViewCell *)collectionViewCellAtRow:(NSInteger)row {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    return (TLCMainCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView selectedCellAtSection:(NSInteger)section {
    return  [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - getter & setter

- (TLCMainViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[TLCMainViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 18, TLCMainViewControllerTableViewMarginBottom, 18);
        
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = 10;
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        CGFloat layoutItemSizeHeight = TLCScreenHeight - [keyWindow TLCBottomSpace] - [keyWindow TLCNavigationBarHeight] - TLCMainViewControllerHeaderLableHeight - TLCMainViewControllerTableViewMarginBottom;
        _flowLayout.itemSize = CGSizeMake(TLCScreenWidth-TLCMainViewControllerFlowLayoutWidthOffset, layoutItemSizeHeight);
    }
    return _flowLayout;
}

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

- (TLCMainViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[TLCMainViewModel alloc] init];
    }
    return _viewModel;
}

- (UIBarButtonItem *)menuItem {
    if (!_menuItem) {
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, 32, 32);
        [menuButton setTitle:@"" forState:UIControlStateNormal];
        [menuButton setImage:TLCSkinImage(@"general_top_icon_more_normal") forState:UIControlStateNormal];
        [menuButton setImage:TLCSkinImage(@"general_top_icon_more_pressed") forState:UIControlStateHighlighted];
        [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
       _menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    }
    return _menuItem; 
}

- (UIBarButtonItem *)remindSettingItem {
    if (!_remindSettingItem) {
        UIButton *remindSetting = [UIButton buttonWithType:UIButtonTypeCustom];
        remindSetting.frame = CGRectMake(0, 0, 32, 32);
        [remindSetting setTitle:@"" forState:UIControlStateNormal];
        [remindSetting setImage:TLCSkinImage(@"transaction_list_alarm_setting_icon") forState:UIControlStateNormal];
        [remindSetting setImage:TLCSkinImage(@"transaction_list_alarm_setting_icon") forState:UIControlStateHighlighted];
        [remindSetting addTarget:self action:@selector(remindSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
        _remindSettingItem = [[UIBarButtonItem alloc] initWithCustomView:remindSetting];
    }
    return _remindSettingItem;
}

- (UILabel *)headerLable {
    if (!_headerLable) {
        _headerLable = [[UILabel alloc] init];
        NSMutableAttributedString *rightAttributeString = [[NSMutableAttributedString alloc] initWithString:TLCLocalizedString(@"TLC_Main_Header_Tip") attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"], NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        NSAttributedString *leftAttribute = [[NSAttributedString alloc] initWithString:@"*" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"ff0000"], NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        
        [rightAttributeString insertAttributedString:leftAttribute atIndex:0];
        _headerLable.attributedText = rightAttributeString;
    }
    return _headerLable;
}

- (TLCMainInputView *)inputProjectView {
    
    if (!_inputProjectView) {
        _inputProjectView = [[TLCMainInputView alloc] initWithFrame:CGRectZero];
        _inputProjectView.delegate = self;
    }
    return _inputProjectView;
}

- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    }
    return _longPress;
}

@end
