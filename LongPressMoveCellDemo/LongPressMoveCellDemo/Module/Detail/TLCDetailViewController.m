//
//  TLCDetailViewController.m
//  APFCompatibleKit
//
//  Created by xulihua on 2017/12/22.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "TLCDetailViewController.h"
#import "TLCDefine.h"
#import "TLCPlaceholderTextView.h"
#import "TLPlanItem.h"
#import "TLCGlobalCommon.h"

#import "UIColor+TLCAdd.h"

typedef NS_ENUM(NSUInteger, TLCDetailViewActionType) {
    TLCDetailViewActionTypeDelete, //删除
    TLCDetailViewActionTypeSave, //保存
};

@interface TLCDetailViewController ()<UITextViewDelegate>

@property (nonatomic, assign) TLCDetailViewActionType actionType;

/**
 返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

/**
 数据对象
 */
@property (nonatomic, strong) TLPlanItem *model;

/**
 菜单导航栏按钮
 */
@property (nonatomic, strong)  UIBarButtonItem *righButtonItem;

/**
 文本输入框
 */
@property (nonatomic, strong) TLCPlaceholderTextView *textView;

/**
 中间的视图
 */
@property (nonatomic, strong) UIView *middleView;

/**
 重点图片
 */
@property (nonatomic, strong) UIImageView *keyPointIcon;

/**
 重点标签
 */
@property (nonatomic, strong) UILabel *keyPointLable;

/**
 开关按钮
 */
@property (nonatomic, strong) UISwitch *signSwitch;

/**
 导航栏右边按钮
 */
@property (nonatomic, strong) UIButton *rightButton;

/**
 提示框
 */
@property (nonatomic, strong) UIAlertController *alterViewController;

/**
 是否为重点标记的初始态
 */
@property (nonatomic, assign) BOOL originalImportState;

/**
 textView是否正在编辑中
 */
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation TLCDetailViewController


#pragma mark - life cycle

- (instancetype)initWithModel:(TLPlanItem *)model {
    self = [super init];
    if (self) {
        _model = [[TLPlanItem alloc] init];
        _model.idStr = model.idStr;
        _model.important = model.important;
        _model.title = model.title;
        _model.finish = model.finish;
        _originalImportState = model.important;
        _actionType = TLCDetailViewActionTypeDelete;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurePageView];
    [self addPageSubviews];
    [self layoutPageSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.alterViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - UI & autolayout

- (void)configurePageView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    self.title = TLCLocalizedString(@"TLCDetailViewController_Project_Detail");
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
    self.navigationItem.rightBarButtonItem = self.righButtonItem; 
}

- (void)addPageSubviews {
    
    [self.middleView addSubview:self.keyPointIcon];
    [self.middleView addSubview:self.keyPointLable];
    [self.middleView addSubview:self.signSwitch];
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.middleView];
}

- (void)layoutPageSubviews {
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.mas_equalTo(189);
    }];
    
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).offset(15);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    
    [self.keyPointIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.middleView).offset(10);
        make.centerY.equalTo(self.middleView);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(16);
    }];
    
    [self.keyPointLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.keyPointIcon.mas_trailing).offset(3);
        make.top.equalTo(self.middleView);
        make.bottom.equalTo(self.middleView);
        make.width.mas_equalTo(100);
    }];
    
    [self.signSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.middleView);
        make.trailing.equalTo(self.middleView).mas_offset(-10);
    }];
}

#pragma mark - event response

- (void)backButtonClicked:(UIButton *)sender {
    
    [self.textView resignFirstResponder];
    if ([self isSendRequestToSaveProject] && [self.textView hasText]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TLCLocalizedString(@"TLCDetailViewController_Tip") message:TLCLocalizedString(@"TLCDetailViewController_Make_Sure_Save_This_Project") preferredStyle:UIAlertControllerStyleAlert];
        self.alterViewController = alertController;
        
        [alertController addAction:[UIAlertAction actionWithTitle:TLCLocalizedString(@"TLCDetailViewController_Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]]; 
        @weakify(self)
        [alertController addAction:[UIAlertAction actionWithTitle:TLCLocalizedString(@"TLCDetailViewController_Save") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveProjectChanges:^(id resData, NSError *err) {
                 @strongify(self)
                if (!err) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }]];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        return;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightButtonItemClicked:(UIButton *)sender {
    
    if (self.actionType == TLCDetailViewActionTypeSave) {
        [self saveProjectChanges:NULL];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TLCLocalizedString(@"TLCDetailViewController_Tip")
                                                                                 message:TLCLocalizedString(@"TLCDetailViewController_Delete_This_Project")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        self.alterViewController = alertController;
        
        [alertController addAction:[UIAlertAction actionWithTitle:TLCLocalizedString(@"TLCDetailViewController_Cancel")
                                                            style:UIAlertActionStyleDefault
                                                          handler:NULL]];
        @weakify(self)
        [alertController addAction:[UIAlertAction actionWithTitle:TLCLocalizedString(@"TLCDetailViewController_Sure")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            [self deleteProject];
        }]];
        [self presentViewController:alertController
                           animated:YES
                         completion:NULL];
    }
}

- (void)signSwitchValueChanged:(UISwitch *)sender {
    
    self.model.important = sender.isOn;
    if ([self isEditingOrImportStateChange]) {
        self.actionType = TLCDetailViewActionTypeSave;
    } else {
        self.actionType = TLCDetailViewActionTypeDelete;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.isEditing = YES;
    [self modifyActionType];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.isEditing = NO;
    [self modifyActionType];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (!textView.hasText) {
        self.rightButton.enabled = NO;
    } else {
        self.rightButton.enabled = YES;
    }
    [self modifyActionType];
}

#pragma mark - private

- (void)modifyActionType {
    
    if ([self isEditingOrImportStateChange]) {
        self.actionType = TLCDetailViewActionTypeSave;
    } else {
        self.actionType = TLCDetailViewActionTypeDelete;
    }
    
    if (!self.textView.hasText) {
        self.actionType = TLCDetailViewActionTypeSave;
    }
}

- (BOOL)isEditingOrImportStateChange {
    return (self.isEditing || [self isImportStateChange]);
}

- (BOOL)isImportStateChange {
    return (!self.model.important && self.originalImportState)
    || (self.model.important && !self.originalImportState);
}

- (BOOL)isSendRequestToSaveProject {
    BOOL isTextChange = ![self.model.title isEqualToString:self.textView.text];
    return [self isEditingOrImportStateChange] || isTextChange;
}

- (void)saveProjectChanges:(TLSDKCompletionBlk)completion {
    [self.textView resignFirstResponder];
    if (![self isSendRequestToSaveProject]) {
        return;
    }
    self.model.title = self.textView.text;
    
    self.actionType = TLCDetailViewActionTypeDelete;
    self.originalImportState = self.model.important;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TLCNotificationUpdatePlan object:self.model];
    
    if (completion) {
        completion(self.model,nil);
    }
}

- (void)deleteProject {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TLCNotificationDeletePlan object:self.model];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter & setter

- (void)setActionType:(TLCDetailViewActionType)actionType {
    _actionType = actionType;
    if (actionType == TLCDetailViewActionTypeSave) {
        [self.rightButton setImage:TLCSkinImage(@"transaction_list_save_icon") forState:UIControlStateNormal];
        self.title = TLCLocalizedString(@"TLCDetailViewController_Project_Edited");
    } else {
        [self.rightButton setImage:TLCSkinImage(@"transaction_list_delete_icon") forState:UIControlStateNormal];
        self.title = TLCLocalizedString(@"TLCDetailViewController_Project_Detail");
    }
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 44, 44);
        
        [_backButton setImage:TLCSkinImage(@"general_top_icon_back_normal_ios") forState:UIControlStateNormal];
        [_backButton setImage:TLCSkinImage(@"general_top_icon_back_pressed_ios") forState:UIControlStateHighlighted];
        
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIBarButtonItem *)righButtonItem {
    if (!_righButtonItem) {
        
        _righButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    }
    return _righButtonItem;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        //正常态为删除，选中态为保存
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(0, 0, 44, 44);
        [_rightButton setImage:TLCSkinImage(@"transaction_list_delete_icon") forState:UIControlStateNormal];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;
        [_rightButton addTarget:self action:@selector(rightButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (TLCPlaceholderTextView *)textView {
    if (!_textView) {
        _textView = [[TLCPlaceholderTextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.placeholder = TLCLocalizedString(@"TLC_Main_Input_View_Placeholder");
        _textView.placeholderColor = [UIColor lightGrayColor];
        _textView.delegate = self;
        _textView.tintColor = [UIColor colorWithHexString:@"333333"];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.text = self.model.title;
    }
    return _textView;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView = [[UIView alloc] init];
        _middleView.backgroundColor = [UIColor whiteColor];
    }
    return _middleView;
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


- (UISwitch *)signSwitch{
    
    if (!_signSwitch) {
        _signSwitch = [[UISwitch alloc] init];
        _signSwitch.on = self.model.important;
        _signSwitch.onTintColor = [UIColor colorWithHexString:@"38adff"];
        [_signSwitch addTarget:self action:@selector(signSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _signSwitch;
} 

@end
