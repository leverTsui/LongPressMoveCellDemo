//
//  TLCNoResultViewModel.m
//  transaction_list_ios
//
//  Created by lever on 2018/1/2.
//  Copyright © 2018年 ND. All rights reserved.
//

#import "TLCNoResultViewModel.h"

@implementation TLCNoResultViewModel

- (void)extracted:(NSString *)imageName tip:(NSString *)tip title:(NSString *)title {
    self.imageName = imageName;
    self.title = title;
    self.tip = tip;
}

- (instancetype)initWithImageName:(NSString *)imageName title:(NSString *)title tip:(NSString *)tip {
    if (self = [super init]) {
        [self extracted:imageName tip:tip title:title];
    }
    return self;
} 

@end
