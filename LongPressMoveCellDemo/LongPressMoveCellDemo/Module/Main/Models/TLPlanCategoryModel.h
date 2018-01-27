//
//  TLTodoModel.h
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TLPlanItem.h"


@interface TLPlanCategoryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray<TLPlanItem *> *today;
@property (nonatomic, copy) NSArray<TLPlanItem *> *next;
@property (nonatomic, copy) NSArray<TLPlanItem *> *future;

@end
