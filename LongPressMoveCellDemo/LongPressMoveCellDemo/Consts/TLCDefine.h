//
//  TLCDefine.h
//  transaction_list_ios
//
//  Created by Chris on 2017/12/19.
//  Copyright © 2017年 ND. All rights reserved.
//

#import <Mantle/EXTScope.h>
#ifndef TLCDefine_h
#define TLCDefine_h 

/**
 语言国际化
 */
#define TLCLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil] 

/**
 根据图片名获取bundle中的图片
 */
#define TLCSkinImage(name) [UIImage imageNamed:name]

/**
 屏幕宽
 */
#define TLCScreenWidth ([UIScreen mainScreen].bounds.size.width)

/**
 屏幕高
 */
#define TLCScreenHeight ([UIScreen mainScreen].bounds.size.height) 


typedef NS_ENUM(NSUInteger, TLSDKPlanType) {
    TLSDKPlanTypeAll,///<全部
    TLSDKPlanTypeToday,///<今日要做
    TLSDKPlanTypeNextStep,///<下一步要做
    TLSDKPlanTypeFuture,///<将来要做
};


typedef void (^TLSDKCompletionBlk) (id resData, NSError *err);

#ifndef MUPArrayObjectAtIndex
#define MUPArrayObjectAtIndex(array, index)                                     \
((index) < [(array) count] && (index) >= 0 ?                           \
[(array) objectAtIndex:(index)] : nil)
#endif

#endif
