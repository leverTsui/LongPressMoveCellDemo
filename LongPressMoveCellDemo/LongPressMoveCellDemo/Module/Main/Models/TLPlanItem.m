//
//  TLPlanItem
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "TLPlanItem.h"


@implementation TLPlanItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"idStr" : @"id",
             @"tenant" : @"tenant",
             @"updateTime" : @"update_time",
             @"createTime" : @"create_time",
             @"version" : @"version",
             @"deleteFlag" : @"delete_flag",
             @"userId" : @"user_id",
             @"userName" : @"user_name",
             @"type" : @"type",
             @"title" : @"title",
             @"spell" : @"spell",
             @"priority" : @"priority",
             @"finish" : @"finish",
             @"finishAt" : @"finish_at",
             @"important" : @"important",
             @"searchCount" : @"search_count"
             };
}

+ (NSValueTransformer *)updateTimeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError **error) {
        NSTimeInterval time = [value longLongValue] * 0.001;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        return date;
    } reverseBlock:^(id value, BOOL *success, NSError **error) {
        NSTimeInterval time = [value timeIntervalSince1970];
        return @([@(time * 1000) longLongValue]);
    }];
}

+ (NSValueTransformer *)createTimeJSONTransformer {
    return [self updateTimeJSONTransformer];
}


@end
