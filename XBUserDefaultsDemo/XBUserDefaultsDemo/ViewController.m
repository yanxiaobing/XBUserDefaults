//
//  ViewController.m
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import "ViewController.h"
#import "XBTestUserDefaults.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:@"我不是小bingbing" forKey:@"test_name"];
    [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"test_age"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"test_date"];
    
    NSDictionary *dic = @{@"name":@"test_name",
                          @"age":@"test_age",
                          @"date":@"test_date",
                          };
    [[XBTestUserDefaults sharedInstance] transferToXBWithNewOldKeysDic:dic];
    
    NSLog(@"name:%@",[XBTestUserDefaults sharedInstance].name);
    NSLog(@"age:%ld",(long)[XBTestUserDefaults sharedInstance].age);
    NSLog(@"date:%@",[XBTestUserDefaults sharedInstance].date);
    [XBTestUserDefaults sharedInstance].testBool = YES;
    
    NSDate *date = [NSDate date];
    for (int i = 0; i<100000; i++) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"我不是小冰冰%d",i] forKey:@"test_name"];
//        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"test_name"];
    }
    NSLog(@"直接使用：%f",[NSDate date].timeIntervalSince1970 - date.timeIntervalSince1970);
    
    NSDate *date2 = [NSDate date];
    for (int i = 0; i<100000; i++) {
    [XBTestUserDefaults sharedInstance].name = [NSString stringWithFormat:@"我不是小冰冰%d",i];
//        NSString *str = [XBTestUserDefaults sharedInstance].name;
    }
    NSLog(@"间接使用：%f",[NSDate date].timeIntervalSince1970 - date2.timeIntervalSince1970);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
