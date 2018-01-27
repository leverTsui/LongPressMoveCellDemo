//
//  TLPlanItem
//  transaction_list_ios
//
//  Created by Chris on 2017/12/20.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TLPlanItem : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, assign) NSInteger tenant;
@property (nonatomic, strong) NSDate *updateTime;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) BOOL deleteFlag;
@property (nonatomic, copy) NSString *userId;///<用户 id
@property (nonatomic, copy) NSString *userName;///<用户名
@property (nonatomic, assign) NSInteger type;///<计划类别，1--今日要做，2--下一步要做，3--将来要做
@property (nonatomic, copy) NSString *title;///<标题
@property (nonatomic, copy) NSString *spell;///<标题拼音,搜索用
@property (nonatomic, assign) NSInteger priority;///<优先级,排序用
@property (nonatomic, assign) BOOL finish;///<是否完成
@property (nonatomic, assign) NSInteger finishAt;///<完成时间
@property (nonatomic, assign) BOOL important;///<是否重要
@property (nonatomic, assign) NSInteger searchCount;///<在搜索结果列表中被选中的次数

@property (nonatomic, assign) double cellHeight;///<cell高度 add by xulihua
@property (nonatomic, assign) BOOL isHidden;///<是否隐藏 add by xulihua

@end
