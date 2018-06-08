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
    [XBTestUserDefaults sharedInstance].name = @"我不是小兵";
    [XBTestUserDefaults sharedInstance].age = 100;
    [XBTestUserDefaults sharedInstance].intAge = 500;
    
    NSLog(@"name:%@",[XBTestUserDefaults sharedInstance].name);
    NSLog(@"age:%ld",(long)[XBTestUserDefaults sharedInstance].age);
    NSLog(@"age:%ld",(long)[XBTestUserDefaults sharedInstance].intAge);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
