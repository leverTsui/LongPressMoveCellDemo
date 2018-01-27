//
//  TLCNoResultViewModel.h
//  transaction_list_ios
//
//  Created by lever on 2018/1/2.
//  Copyright © 2018年 ND. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLCNoResultViewModel : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tip;

- (instancetype)initWithImageName:(NSString *)imageName title:(NSString *)title tip:(NSString *)tip;

@end
