//
//  XBUserDefaults.m
//  XBUserDefaultsDemo
//
//  Created by XBingo on 2018/6/8.
//  Copyright © 2018年 XBingo. All rights reserved.
//

#import "XBUserDefaults.h"
#import <objc/message.h>

enum XBTypeEncodings {

    xb_short                = 's',
    xb_unsigned_short       = 'S',
    xb_int                  = 'i',
    xb_unsigned_int         = 'I',
    xb_long                 = 'l',
    xb_unsigned_long        = 'L',
    xb_longlong             = 'q',
    xb_unsigned_longlong    = 'Q',
    xb_unsigned_char        = 'C',
    
    xb_char                 = 'c',
    xb_bool                 = 'B',
    
    xb_float                = 'f',
    xb_double               = 'd',
    xb_id                   = '@'
};

static NSString *const xb_property_suffix = @"_xb_userDefaults_key";

@interface XBUserDefaults()

@property (nonatomic ,strong) NSUserDefaults *userDefaults;

@end

@implementation XBUserDefaults

@dynamic isXBingoTransfered;

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
        
        char types[5];
        snprintf(types, 5, "v@:%c", type);
        switch (type) {
            case xb_id:
                class_addMethod(self, sel, (IMP)autoIdTypeSetter, types);
                break;
            case xb_float:
                class_addMethod(self, sel, (IMP)autoFloatTypeSetter, types);
                break;
            case xb_double:
                class_addMethod(self, sel, (IMP)autoDoubleTypeSetter, types);
                break;
            case xb_bool:
            case xb_char:
                class_addMethod(self, sel, (IMP)autoBoolTypeSetter, types);
                break;
            case xb_int:
            case xb_long:
                class_addMethod(self, sel, (IMP)autoIntegerTypeSetter, types);
                break;
            case xb_short:
            case xb_longlong:
            case xb_unsigned_long:
            case xb_unsigned_longlong:
            case xb_unsigned_char:
            case xb_unsigned_short:
            case xb_unsigned_int:
                class_addMethod(self, sel, (IMP)autoLongLongTypeSetter, types);
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported type of property \"%@\" in class %@", selName, NSStringFromClass(self)];
                break;
        }
    }else{
        // 获取属性
        objc_property_t property = class_getProperty(self, [selName UTF8String]);
        const char * property_attr = property_getAttributes(property);
        char type = property_attr[1];
        
        char types[5];
        snprintf(types, 4, "%c@:", type);
        switch (type) {
            case xb_id:
                class_addMethod(self, sel, (IMP)autoIdTypeGetter, types);
                break;
            case xb_float:
               class_addMethod(self, sel, (IMP)autoFloatTypeGetter, types);
                break;
            case xb_double:
               class_addMethod(self, sel, (IMP)autoDoubleTypeGetter, types);
                break;
            case xb_bool:
            case xb_char:
                 class_addMethod(self, sel, (IMP)autoBoolTypeGetter, types);
                break;
            case xb_int:
            case xb_long:
                class_addMethod(self, sel, (IMP)autoIntegerTypeGetter, types);
                break;
            case xb_short:
            case xb_unsigned_long:
            case xb_longlong:
            case xb_unsigned_longlong:
            case xb_unsigned_char:
            case xb_unsigned_short:
            case xb_unsigned_int:
                class_addMethod(self, sel, (IMP)autoLongLongTypeGetter, types);
                break;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported type of property \"%@\" in class %@", selName, NSStringFromClass(self)];
                break;
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
static void autoIntegerTypeSetter(id self,SEL _cmd ,long value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setInteger:value forKey:key];
}

static long autoIntegerTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    return [typedSelf.userDefaults integerForKey:key];
}

// longlong
static void autoLongLongTypeSetter(id self,SEL _cmd ,long long value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    NSNumber *number = [NSNumber numberWithLongLong:value];
    [typedSelf.userDefaults setObject:number forKey:key];
}

static long long autoLongLongTypeGetter(id self,SEL _cmd){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, NO);
    NSNumber *number = [typedSelf.userDefaults objectForKey:key];
    return [number longLongValue];
}

// float
static void autoFloatTypeSetter(id self,SEL _cmd ,float value){
    XBUserDefaults *typedSelf = (XBUserDefaults *)self;
    NSString *key = getKeyWithSelector(_cmd, YES);
    [typedSelf.userDefaults setFloat:value forKey:key];
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



#pragma mark -- transferToXBUserDefaults

-(void)transferToXBWithNewOldKeysDic:(NSDictionary *)newOldKeysDic{
    if (!newOldKeysDic) {
        return;
    }
    if (newOldKeysDic.allKeys.count == 0) {
        return;
    }
    if (self.isXBingoTransfered) {
        return;
    }
    //字典去重,获取到映射表(不去重则可能错误的设置成两个同样的newKey-oldKey,导致数据转换错误)
    NSDictionary *mappingDic = [self sortKeyValueWithDictionary:[newOldKeysDic copy]];
    
    [mappingDic.allKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull proprtyName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *newKey = [proprtyName stringByAppendingString:xb_property_suffix];
        NSString *oldKey = mappingDic[proprtyName];
        //如果新旧key相同则不需要转移
        if (![newKey isEqualToString:oldKey]) {
            // 根据属性名称构建方法
            SEL sel = [self createSetterMethodWithProprtyName:proprtyName];
            //根据newKey获取属性类型
            const char *constChar = [proprtyName UTF8String];
            objc_property_t property = class_getProperty(self.class, constChar);
            const char * property_attr = property_getAttributes(property);
            char type = property_attr[1];
            //根据类型取出旧值
            switch (type) {
                case xb_id:
                {
                    NSString *typeStr = [NSString stringWithUTF8String:property_attr];
                    if ([typeStr containsString:@"NSURL"]) {
                        NSURL *url = [self.userDefaults URLForKey:oldKey];
                        ((void(*)(id,SEL,NSURL *))objc_msgSend)((id)self, sel, url);
                    }else{
                        id obj = [self.userDefaults objectForKey:oldKey];
                        ((void(*)(id,SEL,id))objc_msgSend)((id)self, sel, obj);
                    }
                }
                    break;
                case xb_float:
                {
                    float value = [self.userDefaults floatForKey:oldKey];
                    ((void(*)(id,SEL,float))objc_msgSend)((id)self, sel, value);
                }
                    break;
                case xb_double:
                {
                    double value = [self.userDefaults doubleForKey:oldKey];
                    ((void(*)(id,SEL,double))objc_msgSend)((id)self, sel, value);
                }
                    break;
                case xb_bool:
                case xb_char:
                {
                    BOOL boolV = [self.userDefaults boolForKey:oldKey];
                    ((void(*)(id,SEL,BOOL))objc_msgSend)((id)self, sel, boolV);
                }
                    break;
                case xb_int:
                case xb_long:
                {
                    NSInteger value = [self.userDefaults integerForKey:oldKey];
                    ((void(*)(id,SEL,NSInteger))objc_msgSend)((id)self, sel, value);
                }
                    break;
                case xb_unsigned_long:
                case xb_longlong:
                case xb_unsigned_longlong:
                case xb_unsigned_char:
                case xb_unsigned_short:
                case xb_unsigned_int:
                {
                    NSNumber *number = [self.userDefaults objectForKey:oldKey];
                    ((void(*)(id,SEL,long long))objc_msgSend)((id)self, sel, [number longLongValue]);
                }
                    break;
                default:
                    [NSException raise:NSInternalInconsistencyException format:@"Transfer to XBUserdefaults Unsupported type of property \"%@\" in class %@", proprtyName, self];
                    break;
            }
            // 移除旧值
            [self.userDefaults removeObjectForKey:oldKey];
        }
    }];
    self.isXBingoTransfered = YES;
}

-(SEL)createSetterMethodWithProprtyName:(NSString *)proprtyName{
    NSMutableString *key = [proprtyName mutableCopy];
    NSString *uppercaseString = [[key substringToIndex:1] uppercaseString];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:uppercaseString];
    NSString *methodName = [@"set" stringByAppendingString:key];
    methodName = [methodName stringByAppendingString:@":"];
    return NSSelectorFromString(methodName);
}

-(NSDictionary *)sortKeyValueWithDictionary:(NSDictionary *)orDic{
    NSArray *keyList = orDic.allKeys;
    NSSet *set = [NSSet setWithArray:keyList];
    NSArray *sortList = [set allObjects];
    NSMutableDictionary *needDic = [NSMutableDictionary new];
    [sortList enumerateObjectsUsingBlock:^(NSString*  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [needDic setObject:orDic[key] forKey:key];
    }];
    return [needDic copy];
}

@end
