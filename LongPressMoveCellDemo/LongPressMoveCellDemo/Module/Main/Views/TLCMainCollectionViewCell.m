//
//  TLCMainCollectionViewCell.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import "TLCMainCollectionViewCell.h"

#import "TLCProjectCell.h"
#import <Masonry/Masonry.h>
#import "TLCDefine.h"
#import "TLCMainNoResultView.h"
#import "NSString+TLCSizeCalculate.h"
#import "UIColor+TLCAdd.h"

#import <Mantle/EXTScope.h>

static NSString *const TLCMainCollectionViewCellSectionFooter = @"TLCMainCollectionViewCellSectionFooter";

@interface TLCMainCollectionViewCell ()<UITableViewDelegate,
                                        UITableViewDataSource,
                                        TLCProjectCellDelegete>

@property (nonatomic, strong) NSMutableArray<TLPlanItem *> *dataSource;

/**
 头部视图
 */
@property (nonatomic, strong) UIView *headerView;

/**
 列表视图
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 底部视图
 */
@property (nonatomic, strong) UIView *bottomView;

/**
 蓝色竖线
 */
@property (nonatomic, strong) UIView *verticalLine;

/**
 计划数文本
 */
@property (nonatomic, strong) UILabel *projectNumberLabel;

/**
 新建计划按钮
 */
@property (nonatomic, strong) UIButton *newScheduleButton;

/**
 新建计划按钮
 */
@property (nonatomic, strong) TLCMainNoResultView *noResultView;

/**
 头部文本
 */
@property (nonatomic, copy) NSString *title;

/**
 无数据对象模型
 */
@property (nonatomic, strong) TLCNoResultViewModel *noResultModel;

@end

@implementation TLCMainCollectionViewCell

+ (NSString *)identifier {
    return @"TLCMainCollectionViewCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configurePageView];
        [self addPageSubViews];
        [self layoutPageSubView]; 
    }
    return self;
}

- (void)configurePageView {
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.0; 
}

- (void)addPageSubViews {
    [self.headerView addSubview:self.verticalLine];
    [self.headerView addSubview:self.projectNumberLabel];
    
    [self.bottomView addSubview:self.newScheduleButton];
    
    [self.contentView addSubview:self.headerView];
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.bottomView];
}

- (void)layoutPageSubView {
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headerView.mas_centerY);
        make.width.mas_equalTo(3);
        make.height.mas_equalTo(self.projectNumberLabel.font.lineHeight);
        make.leading.equalTo(self.headerView);
    }];
    
    [self.projectNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView);
        make.bottom.equalTo(self.headerView);
        make.leading.equalTo(self.verticalLine.mas_trailing).offset(3);
        make.trailing.equalTo(self.headerView); 
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.height.mas_equalTo(43);
        make.leading.equalTo(self.contentView).offset(12);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(1);
        make.leading.equalTo(self.contentView).offset(12);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.mas_bottom);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(37);
        make.leading.equalTo(self.contentView);
        make.trailing.equalTo(self.contentView);
    }];
    
     CGFloat textWidth = [self.newScheduleButton.titleLabel.text sizeForFont:self.newScheduleButton.titleLabel.font
                                                   size:CGSizeMake(CGFLOAT_MAX, self.newScheduleButton.titleLabel.font.lineHeight)
                                                   mode:NSLineBreakByWordWrapping].width;
    [self.newScheduleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(2);
        make.bottom.equalTo(self.bottomView);
        make.width.mas_equalTo(textWidth+15+24+5);
        make.trailing.equalTo(self.bottomView);
    }];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self adjustNewScheduleButton];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TLCProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:[TLCProjectCell identifier] forIndexPath:indexPath];
    TLPlanItem *model = self.dataSource[indexPath.section];
    cell.delegate = self;
    [cell updateWithModel:model indexPath:indexPath];
    return cell;
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:didSelectTableViewRowAtIndexPath:)]) {
        [self.delegate collectionViewCell:self didSelectTableViewRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TLPlanItem *model = MUPArrayObjectAtIndex(self.dataSource, indexPath.section);
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TLCMainCollectionViewCellSectionFooter];
   footerView.contentView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:scrollViewDidScroll:)]) {
        [self.delegate collectionViewCell:self scrollViewDidScroll:scrollView];
    }
}

#pragma mark - TLCProjectCellDeletate

- (void)tlc_projectCell:(TLCProjectCell *)cell changePlanStateAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:changePlanStateAtIndexPath:)]) {
        [self.delegate collectionViewCell:self changePlanStateAtIndexPath:indexPath];
    }
}

#pragma mark - public

- (void)updateCellWithData:(NSArray<TLPlanItem *> *)data
                 indexpath:(NSIndexPath *)indexPath
                     title:(NSString *)title {
    self.title = title;
    self.dataSource = [data mutableCopy];
    self.indexPath = indexPath;
    [self uploadProjectNumberWithTitle:title projectNumber:data.count];
    [self configureNoPlanView];
    [self reloadCellHeight];
    [self.tableView reloadData];
}

- (void)updateCellWithData:(NSArray<TLPlanItem *> *)data {
    self.dataSource = [data mutableCopy];
    [self uploadProjectNumberWithTitle:self.title projectNumber:data.count];
    [self configureNoPlanView];
    [self reloadCellHeight];
}

- (NSArray<TLPlanItem *> *)currentDataSource {
    return [self.dataSource copy];
}

#pragma mark - private

- (void)reloadCellHeight {
    for (TLPlanItem *item in self.dataSource) {
        item.cellHeight = [TLCProjectCell calculateCellHeightWithModel:item itemWidth:CGRectGetWidth(self.frame) - 24];
    }
}

- (void)uploadProjectNumberWithTitle:(NSString *)title
                       projectNumber:(NSInteger)projectNumber {
    NSMutableAttributedString *rightAttributeString = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSDictionary<NSAttributedStringKey, id> *bracketAttribute = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"], NSFontAttributeName:[UIFont systemFontOfSize:14]};
    NSAttributedString *leftBracket = [[NSAttributedString alloc] initWithString:@" (" attributes:bracketAttribute];
    
    NSAttributedString *numberAttributeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)projectNumber] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"38adff"], NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    NSAttributedString *rightBracket = [[NSAttributedString alloc] initWithString:@")" attributes:bracketAttribute];
    
    if (projectNumber > 0) {
        [rightAttributeString appendAttributedString:leftBracket];
        [rightAttributeString appendAttributedString:numberAttributeString];
        [rightAttributeString appendAttributedString:rightBracket];
    }
    
    self.projectNumberLabel.attributedText = rightAttributeString;
}

- (void)configureNoPlanView {
    if (self.dataSource.count > 0) {
        self.noResultView.hidden = YES;
        return;
    }
    self.noResultView.hidden = NO;
    if (!self.noResultView.superview) {
        [self.tableView addSubview:self.noResultView];
    }
    if (self.indexPath.row == 0) {
        self.noResultModel.tip = TLCLocalizedString(@"TLC_Main_No_Plan_Detail_Title");
    } else {
        self.noResultModel.tip = TLCLocalizedString(@"TLC_Main_No_Plan_Detail_Create_Plan");
    }
    [self.noResultView reloadWithModel:self.noResultModel];
    
    [self.noResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tableView);
        make.width.equalTo(self.tableView);
    }];
}

- (void)adjustNewScheduleButton {
    
    self.newScheduleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12+5, 0, 0);
    self.newScheduleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    
}

#pragma mark - event response

- (void)newScheduleButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:newScheduleAtIndexPath:)]) {
        [self.delegate collectionViewCell:self newScheduleAtIndexPath:self.indexPath];
    }
}
 
#pragma mark - getter & setter

- (UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[TLCProjectCell class] forCellReuseIdentifier:[TLCProjectCell identifier]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:TLCMainCollectionViewCellSectionFooter];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //屏蔽自动计算高度功能，解决移动cell时的抖动问题
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}
 
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];;
    }
    return _bottomView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
    }
    return _headerView;
}

-(UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor colorWithHexString:@"38adff"];
    }
    return _verticalLine;
}

-(UIView *)projectNumberLabel {
    if (!_projectNumberLabel) {
        _projectNumberLabel = [[UILabel alloc] init];
        _projectNumberLabel.numberOfLines = 1;
        _projectNumberLabel.font = [UIFont systemFontOfSize:14];
        _projectNumberLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _projectNumberLabel;
}
 
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIButton *)newScheduleButton {
    if (!_newScheduleButton) {
        _newScheduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _newScheduleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _newScheduleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [_newScheduleButton setTitle:TLCLocalizedString(@"TLC_Main_New_Schedule") forState:UIControlStateNormal];
        [_newScheduleButton setTitleColor:[UIColor colorWithHexString:@"38adff"] forState:UIControlStateNormal];
        
        _newScheduleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [_newScheduleButton setImage:TLCSkinImage(@"transaction_list_new_project_icon") forState:UIControlStateNormal];
        
        [_newScheduleButton addTarget:self action:@selector(newScheduleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newScheduleButton;
}

- (TLCMainNoResultView *)noResultView {
    if (!_noResultView) {
        _noResultView = [[TLCMainNoResultView alloc] initWithFrame:CGRectZero model:self.noResultModel];
    }
    return _noResultView;
}

- (TLCNoResultViewModel *)noResultModel {
    if (!_noResultModel) {
        _noResultModel = [[TLCNoResultViewModel alloc] initWithImageName:@"transaction_list_no_plan_icon"
                                                                  title:TLCLocalizedString(@"TLC_Main_No_Plan_Title")
                                                                    tip:TLCLocalizedString(@"TLC_Main_No_Plan_Detail_Title")];
    }
    return _noResultModel;
}

@end

