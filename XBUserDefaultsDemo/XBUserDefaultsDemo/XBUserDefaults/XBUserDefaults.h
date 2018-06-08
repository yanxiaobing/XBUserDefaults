//
//  XBUserDefaults.h
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import <Foundation/Foundation.h>

/***************
 类型参照
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 c——A char
 i——An int
 s——A short
 l——A long（l is treated as a 32-bit quantity on 64-bit programs.）
 q——A long long
 C——An unsigned char
 I——An unsigned int
 S——An unsigned short
 L——An unsigned long
 Q——An unsigned long long
 f——A float
 d——A double
 B——A C++ bool or a C99 _Bool
 v——A void
 *——A character string (char *)
 @——An object (whether statically typed or typed id)
 #——A class object (Class)
 :——A method selector (SEL)
 [array type]——An array
 {name=type...}——A structure
 (name=type...)——A union
 bnum——A bit field of num bits
 ^type——A pointer to type
 ?——An unknown type (among other things, this code is used for function pointers)
 ***********/

@interface XBUserDefaults : NSObject

/**
 用于替换旧项目中其他方式使用[NSUserDefaults standardUserDefaults]

 @param newOldKeysDic 通过配置改映射表将旧方式保存的值用新方式接收
 key-value 均为NSString类型，格式如下：
  @{@"proprety_name1":@"old_key1",@"proprety_name2":@"old_key2"}
 */
-(void)transferToXBWithNewOldKeysDic:(NSDictionary *)newOldKeysDic;

/**
 用来标记已经执行过数据转移了
 */
@property (nonatomic ,assign) BOOL isXBingoTransfered;

@end
