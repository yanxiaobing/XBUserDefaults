//
//  XBUserDefaults.m
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import "XBUserDefaults.h"
#import <objc/runtime.h>

@interface XBUserDefaults()

@property (nonatomic ,strong) NSUserDefaults *userDefaults;

@end

static const char xb_id = '@';

static const char xb_bool = 'B';

static const char xb_double = 'd';

static const char xb_float = 'f';

static const char xb_int = 'i';
static const char xb_unsigned_int = 'I';

static const char xb_short = 's';
static const char xb_unsigned_short = 'S';

static const char xb_long = 'l';
static const char xb_unsigned_long = 'L';

static const char xb_longlong = 'q';
static const char xb_unsigned_longlong = 'Q';

static NSString *const xb_property_suffix = @"_xb_userDefaults_key";

@implementation XBUserDefaults

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

+(BOOL)resolveInstanceMethod:(SEL)sel{
    
    NSString *selName = NSStringFromSelector(sel);
    
    if ([selName hasPrefix:@"set"]) {
        // 获取属性名
        const char *constChar = getPropertyNameFromSetSelector(sel);
        // 获取属性
        objc_property_t property = class_getProperty(self, constChar);
        const char * property_attr = property_getAttributes(property);
        char type = property_attr[1];
        
        if (type == xb_id) {
            class_addMethod(self, sel, (IMP)autoIdTypeSetter, "v@:@");
        }else if (type == xb_bool) {
            class_addMethod(self, sel, (IMP)autoBoolTypeSetter, "v@:B");
        }else if(type == xb_double){
            class_addMethod(self, sel, (IMP)autoDoubleTypeSetter, "v@:d");
        }else if(type == xb_float){
            class_addMethod(self, sel, (IMP)autoFloatTypeSetter, "v@:f");
        }else if (isIntegerType(type)){
            class_addMethod(self, sel, (IMP)autoIntegerTypeSetter, "v@:q");
        }else{
            // TODO 抛出异常
            NSException *exception  = [NSException exceptionWithName:@"XBUserDefaults exception" reason:@"setter method exception(property type isn`t supported)" userInfo:nil];
            [exception raise];
        }
    }else{
        // 获取属性
        objc_property_t property = class_getProperty(self, [selName UTF8String]);
        const char * property_attr = property_getAttributes(property);
        char type = property_attr[1];
        if (type == xb_id) {
            class_addMethod(self, sel, (IMP)autoIdTypeGetter, "@@:");
        }else if (type == xb_bool) {
            class_addMethod(self, sel, (IMP)autoBoolTypeGetter, "B@:");
        }else if(type == xb_double){
            class_addMethod(self, sel, (IMP)autoDoubleTypeGetter, "d@:");
        }else if(type == xb_float){
            class_addMethod(self, sel, (IMP)autoFloatTypeGetter, "f@:");
        }else if (isIntegerType(type)){
            class_addMethod(self, sel, (IMP)autoIntegerTypeGetter, "q@:");
        }else{
            // TODO 抛出异常
            NSException *exception  = [NSException exceptionWithName:@"XBUserDefaults exception" reason:@"getter method exception (property type isn`t supported)" userInfo:nil];
            [exception raise];
        }
    }
    return YES;
}

static NSString *getKeyWithSelector(SEL _cmd , BOOL isSet){
    NSString *str = nil;
    if (isSet) {
        const char* propertyType = getPropertyNameFromSetSelector(_cmd);
        NSString *propertySet = [NSString stringWithUTF8String:propertyType];
        str = [propertySet stringByAppendingString:xb_property_suffix];
    }else{
        NSString *propertyGet = NSStringFromSelector(_cmd);
        str = [propertyGet stringByAppendingString:xb_property_suffix];
    }
    return str;
}

static BOOL isIntegerType(char type){
    BOOL isInt = type == xb_int || type == xb_unsigned_int;
    BOOL isShort = type == xb_short || type == xb_unsigned_short;
    BOOL isLong = type == xb_long || type == xb_unsigned_long;
    BOOL isLongLong = type == xb_longlong || type == xb_unsigned_longlong;
    BOOL isInteger = isInt || isShort || isLong || isLongLong;
    return isInteger;
}

static const char* getPropertyNameFromSetSelector(SEL _cmd){
    // 获取方法名  setProperty:
    NSString *selName = NSStringFromSelector(_cmd);
    NSMutableString *key = [selName mutableCopy];
    // 删除 ":"
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    // 删除 "set" 前缀
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    //将属性名首字母小写
    NSString *lowrCaseFirstChar = [[key substringToIndex:1] lowercaseString];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:lowrCaseFirstChar];
    const char *constChar = [key UTF8String];
    return constChar;
}

#pragma mark -- 类型动态方法
// integer
static void autoIntegerTypeSetter(id self,SEL _cmd ,long long value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setInteger:value forKey:key];
    [typedSelf.userDefaults synchronize];
}

static long long autoIntegerTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    return [typedSelf.userDefaults integerForKey:key];
}

// float
static void autoFloatTypeSetter(id self,SEL _cmd ,float value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setFloat:value forKey:key];
    [typedSelf.userDefaults synchronize];
}

static float autoFloatTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    return [typedSelf.userDefaults floatForKey:key];
}

// double
static void autoDoubleTypeSetter(id self,SEL _cmd ,double value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setDouble:value forKey:key];
    [typedSelf.userDefaults synchronize];
}

static double autoDoubleTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    return [typedSelf.userDefaults doubleForKey:key];
}

// bool
static void autoBoolTypeSetter(id self,SEL _cmd ,bool value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setBool:value forKey:key];
}

static BOOL autoBoolTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    return [typedSelf.userDefaults boolForKey:key];
}

// id
static void autoIdTypeSetter(id self,SEL _cmd ,id value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    if (!value) {
        [typedSelf.userDefaults removeObjectForKey:key];
    }else if ([value isKindOfClass:NSURL.class]) {
        [typedSelf.userDefaults setURL:(NSURL *)value forKey:key];
    }else{
        [typedSelf.userDefaults setObject:value forKey:key];
        [typedSelf.userDefaults synchronize];
    }
}

static id autoIdTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    
    NSString *propertyKey = NSStringFromSelector(_cmd);
    objc_property_t property = class_getProperty(typedSelf.class, [propertyKey UTF8String]);
    const char * property_attr = property_getAttributes(property);
    NSString *type = [NSString stringWithUTF8String:property_attr];
    
    NSString *key = getKeyWithSelector(_cmd, NO);
    if ([type containsString:@"NSURL"]) {
        return [typedSelf.userDefaults URLForKey:key];
    }else{
        return [typedSelf.userDefaults objectForKey:key];
    }
}

@end
