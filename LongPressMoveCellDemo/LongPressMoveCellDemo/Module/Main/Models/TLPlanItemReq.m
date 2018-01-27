//
//  TLTodoItemReq.m
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "TLPlanItemReq.h"

@implementation TLPlanItemReq

/**
 字典模型数据装换 <MUPJSONSerializing>接口方法
 
 @return NSDictionary
 */
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title":@"title",
             @"type":@"type",
             @"important":@"important"
             };
}
@end
