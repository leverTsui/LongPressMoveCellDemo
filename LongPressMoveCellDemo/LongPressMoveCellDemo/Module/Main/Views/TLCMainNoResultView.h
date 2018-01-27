//
//  TLCMainNoResultView.h
//  transaction_list_ios
//
//  Created by lever on 2018/1/2.
//  Copyright © 2018年 ND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLCNoResultViewModel.h"

@interface TLCMainNoResultView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(TLCNoResultViewModel *)model;

- (void)reloadWithModel:(TLCNoResultViewModel *)model;

@end
