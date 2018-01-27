//
//  TLTodoItemReq.h
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "TLCDefine.h"

@interface TLPlanItemReq : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *title;///< 标题
@property (nonatomic, assign) TLSDKPlanType type;///< 计划类型
@property (nonatomic, assign) BOOL important;///< 是否重要

@end
