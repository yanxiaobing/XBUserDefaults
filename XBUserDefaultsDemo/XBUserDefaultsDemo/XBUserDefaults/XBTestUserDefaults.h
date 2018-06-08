//
//  XBTestUserDefaults.h
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import "XBUserDefaults.h"

@interface XBTestUserDefaults : XBUserDefaults

@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,assign) NSInteger age;
@property (nonatomic ,assign) int intAge;

+(instancetype)sharedInstance;

@end
