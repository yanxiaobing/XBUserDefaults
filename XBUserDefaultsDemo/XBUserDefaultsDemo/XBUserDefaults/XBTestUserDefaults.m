//
//  XBTestUserDefaults.m
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import "XBTestUserDefaults.h"

@implementation XBTestUserDefaults

@dynamic name,age,intAge,date;

static XBTestUserDefaults* _instance = nil;

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}



@end
