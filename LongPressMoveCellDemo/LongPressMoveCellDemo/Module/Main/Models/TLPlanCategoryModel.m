//
//  TLTodoModel.m
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "TLPlanCategoryModel.h"

@implementation TLPlanCategoryModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"today" : @"today",
             @"next" : @"next",
             @"future" : @"future",
             };
}

/**
 数据类型转换器
 
 @return NSValueTransformer
 */
+ (NSValueTransformer *)todayJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TLPlanItem class]];
}

+ (NSValueTransformer *)nextJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TLPlanItem class]];
}

+ (NSValueTransformer *)futureJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TLPlanItem class]];
}

- (void)setNilValueForKey:(NSString *)key {
    [self setValue:[NSArray array] forKey:key]; 
}
@end
