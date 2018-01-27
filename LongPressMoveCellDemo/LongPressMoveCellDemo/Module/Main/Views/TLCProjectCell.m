//
//  TCLProjectCell.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/21.
//

#import "TLCProjectCell.h"
#import "TLCDefine.h"
#import <Masonry/Masonry.h>
#import "NSString+TLCSizeCalculate.h"
#import "UIColor+TLCAdd.h"

static const CGFloat TLCProjectCellSelectButtonMarginLeft = 4;
static const CGFloat TLCProjectCellSelectButtonMarginWidth = 30;
static const CGFloat TLCProjectCellSelectButtonMarginHeight = 38;

static const CGFloat TLCProjectCellContentLableMarginRight = 10;
static const CGFloat TLCProjectCellContentLableMarginTop = 10;

static const CGFloat TLCProjectCellKeyPointLableMarginTop = 5;
static const CGFloat TLCProjectCellKeyPointLableMarginBottom = 8;

@interface TLCProjectCell ()

/**
 选择框按钮
 */
@property (nonatomic, strong) UIButton *selectButton;

/**
 内容标签
 */
@property (nonatomic, strong) UILabel *contentLable;

/**
 重点图片
 */
@property (nonatomic, strong) UIImageView *keyPointIcon;

/**
 重点标签
 */
@property (nonatomic, strong) UILabel *keyPointLable;

/**
 数据模型
 */
@property (nonatomic, strong) TLPlanItem *model;

/**
 位置
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation TLCProjectCell


+ (NSString *)identifier {
    return @"TCLProjectCell";
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier { 
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configurePageView];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (void)configurePageView {
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithHexString:@"dddddd"].CGColor;
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 4.0;
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)addPageSubviews {
    [self.contentView addSubview:self.selectButton];
    [self.contentView addSubview:self.contentLable];
    [self.contentView addSubview:self.keyPointIcon];
    [self.contentView addSubview:self.keyPointLable];
}

- (void)layoutPageSubviews {
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(TLCProjectCellSelectButtonMarginLeft);
        make.width.mas_equalTo(TLCProjectCellSelectButtonMarginWidth);
        make.height.mas_equalTo(TLCProjectCellSelectButtonMarginHeight);
    }]; 
}

#pragma mark - public 

- (void)updateWithModel:(TLPlanItem *)model indexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    self.model = model;
    
    self.keyPointIcon.hidden = !self.model.important;
    self.keyPointLable.hidden = !self.model.important;
    
    self.hidden = self.model.isHidden;
    
    if (model.important) {
        [self.contentLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(TLCProjectCellContentLableMarginTop);
            make.leading.equalTo(self.selectButton.mas_trailing);
            make.trailing.equalTo(self.contentView).offset(-TLCProjectCellContentLableMarginRight);
            make.bottom.equalTo(self.keyPointLable.mas_top).offset(-TLCProjectCellKeyPointLableMarginTop);
        }];
        
        [self.keyPointIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.selectButton);
            make.centerY.equalTo(self.keyPointLable);
            make.width.mas_equalTo(16);
            make.height.mas_equalTo(16);
        }];
        
        [self.keyPointLable mas_remakeConstraints:^(MASConstraintMaker *make) { 
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-TLCProjectCellKeyPointLableMarginBottom);
            make.leading.equalTo(self.contentLable);
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-10);
        }];
    } else {
        [self.contentLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(TLCProjectCellContentLableMarginTop);
            make.leading.equalTo(self.selectButton.mas_trailing);
            make.trailing.equalTo(self.contentView).offset(-TLCProjectCellContentLableMarginRight);
            make.bottom.equalTo(self.contentView).offset(-TLCProjectCellContentLableMarginTop);
        }];
    }
    
    self.selectButton.selected = self.model.finish;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.model.title];
    NSInteger length = self.model.title.length;
    if (self.model.finish) {
        [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                                range:NSMakeRange(0, length)];
        
        // FIX iOS 10.3: NSStrikethroughStyleAttributeName is not rendered
        [attributeString addAttribute:NSBaselineOffsetAttributeName
                                value:@0
                                range:NSMakeRange(0, length)];

        [attributeString addAttribute:NSStrikethroughColorAttributeName
                                value:[UIColor colorWithHexString:@"999999"]
                                range:NSMakeRange(0, length)];
        
        [attributeString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithHexString:@"999999"]
                                range:NSMakeRange(0, length)];
    } else {
        [attributeString addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithHexString:@"333333"]
                                range:NSMakeRange(0, length)];
    }
    
    [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, length)];
    self.contentLable.attributedText = attributeString;
}

+ (CGFloat)calculateCellHeightWithModel:(TLPlanItem *)model itemWidth:(CGFloat)itemWidth {
    CGFloat totalHeight = 0;
    
    //内容高度
    CGFloat calculateWidth = itemWidth - TLCProjectCellSelectButtonMarginLeft - TLCProjectCellSelectButtonMarginWidth - TLCProjectCellContentLableMarginRight;
    CGFloat contentLableHeight = ceilf([model.title sizeForFont:[UIFont systemFontOfSize:14.0] size:CGSizeMake(calculateWidth, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].height);
    if (contentLableHeight > 51) {
        contentLableHeight = 51;
    }
    
    totalHeight += TLCProjectCellContentLableMarginTop;
    totalHeight += contentLableHeight;
    if (model.important) {
        totalHeight += TLCProjectCellKeyPointLableMarginTop;
        CGFloat keyPointLableHeight = [UIFont systemFontOfSize:10.0].lineHeight;
        totalHeight += keyPointLableHeight;
        totalHeight += TLCProjectCellKeyPointLableMarginBottom;
    } else {
        //内容标签离底部跟离顶部一样
        totalHeight += TLCProjectCellContentLableMarginTop;
    }
    
    //最小38
    if (totalHeight < 38) {
        totalHeight = 38;
    }
    return totalHeight;
}

#pragma mark - event response

- (void)selectButtonCliked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tlc_projectCell:changePlanStateAtIndexPath:)]) {
        
        [self.delegate tlc_projectCell:self changePlanStateAtIndexPath:self.indexPath];
    }
}

#pragma mark - getter & setter

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.imageView.contentMode = UIViewContentModeCenter;
        _selectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [_selectButton setImage:TLCSkinImage(@"transaction_list_select_icon_normal") forState:UIControlStateNormal];
        [_selectButton setImage:TLCSkinImage(@"transaction_list_select_icon_normal") forState:UIControlStateHighlighted];
        [_selectButton setImage:TLCSkinImage(@"transaction_list_select_icon_selected") forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UILabel *)contentLable {
    if (!_contentLable) {
        _contentLable = [[UILabel alloc] init];
        _contentLable.font = [UIFont systemFontOfSize:14];
        _contentLable.numberOfLines = 3;
        _contentLable.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLable.textColor = [UIColor colorWithHexString:@"333333"];
    }
    return _contentLable;
}

- (UIImageView *)keyPointIcon {
    if (!_keyPointIcon) {
        _keyPointIcon = [[UIImageView alloc] init];
        _keyPointIcon.image = TLCSkinImage(@"transaction_list_sign_icon");
    }
    return _keyPointIcon;
}

- (UILabel *)keyPointLable {
    if (!_keyPointLable) {
        _keyPointLable = [[UILabel alloc] init];
        _keyPointLable.font = [UIFont systemFontOfSize:10];
        _keyPointLable.numberOfLines = 1;
        _keyPointLable.lineBreakMode = NSLineBreakByTruncatingTail;
        _keyPointLable.tintColor = [UIColor colorWithHexString:@"999999"];
        _keyPointLable.text = TLCLocalizedString(@"TLC_Main_Key_Point");
    }
    return _keyPointLable;
}

@end
