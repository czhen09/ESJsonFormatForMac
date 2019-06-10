//
//  ESJsonFormatManager.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28. Change by ZX on 17/5/17
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESJsonFormatManager.h"
#import "ESClassInfo.h"
#import "ESFormatInfo.h"
#import "ESClassInfo.h"
#import "ESPair.h"
#import "ESJsonFormat.h"
#import "ESJsonFormatSetting.h"
#import "ESPbxprojInfo.h"
#import "ESClassInfo.h"


@interface ESJsonFormatManager()

@property (class, nonatomic, strong, readonly) NSDictionary * dicSwitch;

@end

@implementation ESJsonFormatManager

+(NSDictionary *)dicSwitch{
    return @{
             @"id": @"ID",
             @"description": @"desc",
             };
}

+ (NSString *)parsePropertyContentWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *resultStr = [NSMutableString string];
    NSDictionary *dic = classInfo.classDic;
    
    NSArray * list = [dic.allKeys sortedArrayUsingSelector:@selector(compare:)];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *obj = dic[key];
        if ([NSUserDefaults.standardUserDefaults boolForKey:@"isSwift"]) {
            [resultStr appendFormat:@"\n%@\n",[self formatSwiftWithKey:key value:obj classInfo:classInfo]];
        } else {
            [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj classInfo:classInfo]];
        }
    }];
    return resultStr;
}

//+ (NSString *)parsePropertyContentWithClassInfo:(ESClassInfo *)classInfo{
//    NSMutableString *resultStr = [NSMutableString string];
//    NSDictionary *dic = classInfo.classDic;
//    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
//        if ([NSUserDefaults.standardUserDefaults boolForKey:@"isSwift"]) {
//            [resultStr appendFormat:@"\n%@\n",[self formatSwiftWithKey:key value:obj classInfo:classInfo]];
//        }else{
//            [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj classInfo:classInfo]];
//        }
//    }];
//    return resultStr;
//}

/**
 *  格式化OC属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  @return NSString
 */
+ (NSString *)formatObjcWithKey:(NSString *)key value:(NSObject *)value classInfo:(ESClassInfo *)classInfo{
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    //判断大小写
    if ([self.dicSwitch.allKeys containsObject:key] && ESJsonFormatSetting.defaultSetting.uppercaseKeyWordForId) {
        key = self.dicSwitch[key];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
        
    } else if ([value isKindOfClass:[@(YES) class]]){
        //the 'NSCFBoolean' is private subclass of 'NSNumber'
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
        
    } else if ([value isKindOfClass:[NSNumber class]]){
        qualifierStr = @"assign";
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location != NSNotFound){
            typeStr = @"CGFloat";
        } else {
            NSNumber *valueNumber = (NSNumber *)value;
            if (valueNumber.longValue < 2147483648) {
                typeStr = @"NSInteger";
            } else {
                typeStr = @"long long";
            }
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
        
    } else if ([value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)value;
        
        //May be 'NSString'，will crash
        NSString *genericTypeStr = @"";
        NSObject *firstObj = array.firstObject;
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *childInfo = classInfo.propertyArrayDic[key];
            genericTypeStr = [NSString stringWithFormat:@"<%@ *>",childInfo.className];
        } else if ([firstObj isKindOfClass:[NSString class]]){
            genericTypeStr = @"<NSString *>";
        } else if ([firstObj isKindOfClass:[NSNumber class]]){
            genericTypeStr = @"<NSNumber *>";
        }
        
        qualifierStr = @"strong";
        typeStr = @"NSArray";
        if (ESJsonFormatSetting.defaultSetting.useGeneric && [ESUtils isXcode7AndLater]) {
            return [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@ *%@;",qualifierStr,typeStr,genericTypeStr,key];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
        
    } else if ([value isKindOfClass:[NSDictionary class]]){
        qualifierStr = @"strong";
        ESClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
}


/**
 *  格式化Swift属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  @return NSString
 */
+ (NSString *)formatSwiftWithKey:(NSString *)key value:(NSObject *)value classInfo:(ESClassInfo *)classInfo{
    NSString *typeStr = @"String?";
    //判断大小写
    if ([self.dicSwitch.allKeys containsObject:key] && ESJsonFormatSetting.defaultSetting.uppercaseKeyWordForId) {
        key = self.dicSwitch[key];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
        
    } else if ([value isKindOfClass:[@(YES) class]]){
        typeStr = @"Bool";
        return [NSString stringWithFormat:@"    var %@: %@ = false",key,typeStr];
        
    } else if ([value isKindOfClass:[NSNumber class]]){
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"Double";
        } else {
            typeStr = @"Int";
        }
        return [NSString stringWithFormat:@"    var %@: %@ = 0",key,typeStr];
        
    } else if ([value isKindOfClass:[NSArray class]]){
        ESClassInfo *childInfo = classInfo.propertyArrayDic[key];
        NSString *type = childInfo.className;
        return [NSString stringWithFormat:@"    var %@: [%@]?",key,type == nil ? @"String" : type];
        
    } else if ([value isKindOfClass:[NSDictionary class]]){
        ESClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"    var %@: %@?",key,typeStr];
    }
    return [NSString stringWithFormat:@"    var %@: %@",key,typeStr];
}


+ (NSString *)parseClassHeaderContentWithClassInfo:(ESClassInfo *)classInfo{
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"isSwift"]) {
        return [self parseClassContentForSwiftWithClassInfo:classInfo];
    } else {
        return [self parseClassHeaderContentForOjbcWithClassInfo:classInfo];
    }
}

+ (NSString *)parseClassImpContentWithClassInfo:(ESClassInfo *)classInfo{
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"isSwift"]) {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:@""];
    if (ESJsonFormatSetting.defaultSetting.impOjbClassInArray) {
        
        BOOL isYYModel = [NSUserDefaults.standardUserDefaults boolForKey:@"isYYModel"];
         if (isYYModel) {
            [result appendFormat:@"\n@implementation %@\n%@\n%@\n@end\n",classInfo.className,[self methodContentOfObjectClassInArrayWithClassInfo:classInfo],[self methodContentOfObjectIDInArrayWithClassInfo:classInfo]];
            
        } else {
            [result appendFormat:@"\n@implementation %@\n%@\n@end\n",classInfo.className,[self methodContentOfObjectClassInArrayWithClassInfo:classInfo]];
            
        }
        
    } else {
        [result appendFormat:@"@implementation %@\n\n@end\n",classInfo.className];
    }
    
    if (ESJsonFormatSetting.defaultSetting.outputToFiles) {
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"m"]];
        //import
        [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",classInfo.className]];
        for (NSString *key in classInfo.propertyArrayDic) {
            ESClassInfo *childClassInfo = classInfo.propertyArrayDic[key];
            [headerString appendString:[NSString stringWithFormat:@"#import \"%@.h\"\n",childClassInfo.className]];
        }
        [headerString appendString:@"\n"];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}

/**
 *  解析.h文件内容--Objc
 *
 *  @param classInfo 类信息
 *
 *  @return NSString
 */
+ (NSString *)parseClassHeaderContentForOjbcWithClassInfo:(ESClassInfo *)classInfo{
    NSString *superClassString = [NSUserDefaults.standardUserDefaults valueForKey:@"SuperClass"];
    NSMutableString *result = nil;
    if (superClassString&&superClassString.length>0) {
        result = [NSMutableString stringWithFormat:@"\n\n@interface %@ : %@\n",classInfo.className,superClassString];
    } else {
        result = [NSMutableString stringWithFormat:@"\n\n@interface %@ : NSObject\n",classInfo.className];
    }
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n@end"];
    
    if (ESJsonFormatSetting.defaultSetting.outputToFiles) {
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"h"]];
        //@class
        [headerString appendString:[NSString stringWithFormat:@"%@\n\n",classInfo.atClassContent]];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}

/**
 *  解析.swift文件内容--Swift
 *
 *  @param classInfo 类信息
 *
 *  @return NSString
 */
+ (NSString *)parseClassContentForSwiftWithClassInfo:(ESClassInfo *)classInfo{
    NSString *superClassString = [NSUserDefaults.standardUserDefaults valueForKey:@"SuperClass"];
    NSMutableString *result = nil;
    if (superClassString&&superClassString.length>0) {
        result = [NSMutableString stringWithFormat:@"@interface %@ : %@\n",classInfo.className,superClassString];
    } else {
        result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n",classInfo.className];
    }
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n}"];
    if (ESJsonFormatSetting.defaultSetting.outputToFiles) {
        [result insertString:@"import UIKit\n\n" atIndex:0];
        //headerStr
        NSMutableString *headerString = [NSMutableString stringWithString:[self dealHeaderStrWithClassInfo:classInfo type:@"swift"]];
        [result insertString:headerString atIndex:0];
    }
    return [result copy];
}


/**
 *  生成 MJExtension 的集合中指定对象的方法
 *
 *  @param classInfo 指定类信息
 *
 *  @return NSString
 */
+ (NSString *)methodContentOfObjectClassInArrayWithClassInfo:(ESClassInfo *)classInfo{
    
    if (classInfo.propertyArrayDic.count==0) {
        return @"";
    } else {
        NSMutableString *result = [NSMutableString string];
        for (NSString *key in classInfo.propertyArrayDic) {
            ESClassInfo *childClassInfo = classInfo.propertyArrayDic[key];
            [result appendFormat:@"@\"%@\" : [%@ class], ",key,childClassInfo.className];
        }
        if ([result hasSuffix:@", "]) {
            result = [NSMutableString stringWithFormat:@"%@",[result substringToIndex:result.length-2]];
        }
        
        BOOL isYYModel = [NSUserDefaults.standardUserDefaults boolForKey:@"isYYModel"];
        NSString *methodStr = nil;
        if (isYYModel) {
            //append method content (objectClassInArray) if YYModel
            methodStr = [NSString stringWithFormat:@"\n+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass{\n    return @{%@};\n}\n",result];
            
        } else {
            // append method content (objectClassInArray)
            methodStr = [NSString stringWithFormat:@"\n+ (NSDictionary *)objectClassInArray{\n    return @{%@};\n}\n",result];
            
        }
        return methodStr;
    }
}


+ (NSString *)methodContentOfObjectIDInArrayWithClassInfo:(ESClassInfo *)classInfo{
    
    NSMutableString *result = [NSMutableString string];
    NSDictionary *dic = classInfo.classDic;
    NSLog(@"%@",dic);
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
//        NSLog(@"%@: _%@_",key,obj);
        if ([self.dicSwitch.allKeys containsObject:key] && ESJsonFormatSetting.defaultSetting.uppercaseKeyWordForId) {
            [result appendFormat:@"@\"%@\": @\"%@\", ",self.dicSwitch[key],key];
        }
    }];
    
    if ([result hasSuffix:@", "]) {
        result = [NSMutableString stringWithFormat:@"%@",[result substringToIndex:result.length-2]];
        NSString *methodStr = [NSString stringWithFormat:@"\n+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{\n    return @{%@};\n}\n",result];
        return methodStr;
    }
    return result;
}

/**
 *  拼装模板信息
 *
 *  @param classInfo 类信息
 *  @param type      .h或者.m或者.swift
 *
 *  @return NSString
 */
+ (NSString *)dealHeaderStrWithClassInfo:(ESClassInfo *)classInfo type:(NSString *)type{
    //模板文字
    NSString *templateFile = [ESJsonFormatPluginPath stringByAppendingPathComponent:@"Contents/Resources/DataModelsTemplate.txt"];
    NSString *templateString = [NSString stringWithContentsOfFile:templateFile encoding:NSUTF8StringEncoding error:nil];
    //替换模型名字
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__MODELNAME__" withString:[NSString stringWithFormat:@"%@.%@",classInfo.className,type]];
    //替换用户名
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__NAME__" withString:NSFullUserName()];
    //产品名
    NSString *productName = ESPbxprojInfo.shareInstance.productName;
    if (productName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__PRODUCTNAME__" withString:productName];
    }
    //组织名
    NSString *organizationName = ESPbxprojInfo.shareInstance.organizationName;
    if (organizationName.length) {
        templateString = [templateString stringByReplacingOccurrencesOfString:@"__ORGANIZATIONNAME__" withString:organizationName];
    }
    //时间
    templateString = [templateString stringByReplacingOccurrencesOfString:@"__DATE__" withString:[self dateStr]];
    
    if ([type isEqualToString:@"h"] || [type isEqualToString:@"switf"]) {
        NSMutableString *string = [NSMutableString stringWithString:templateString];
        if ([type isEqualToString:@"h"]) {
            [string appendString:@"#import <Foundation/Foundation.h>\n\n"];
            NSString *superClassString = [NSUserDefaults.standardUserDefaults valueForKey:@"SuperClass"];
            if (superClassString&&superClassString.length>0) {
                [string appendString:[NSString stringWithFormat:@"#import \"%@.h\" \n\n",superClassString]];
            }
        } else {
            [string appendString:@"import UIKit\n\n"];
            NSString *superClassString = [NSUserDefaults.standardUserDefaults valueForKey:@"SuperClass"];
            if (superClassString&&superClassString.length>0) {
                [string appendString:[NSString stringWithFormat:@"import %@ \n\n",superClassString]];
            }
        }
        templateString = [string copy];
    }
    return [templateString copy];
}

/**
 *  返回模板信息里面日期字符串
 *
 *  @return NSString
 */
+ (NSString *)dateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yy/MM/dd";
    return [formatter stringFromDate: NSDate.date];
}


+ (void)createFileWithFolderPath:(NSString *)folderPath classInfo:(ESClassInfo *)classInfo{
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"isSwift"]) {
        //创建.h文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",classInfo.className]] content:classInfo.classContentForH];
        //创建.m文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",classInfo.className]] content:classInfo.classContentForM];
    } else {
        //创建.swift文件
        [self createFileWithFileName:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.swift",classInfo.className]] content:classInfo.classContentForH];
    }
}

/**
 *  创建文件
 *
 *  @param FileName 文件名字
 *  @param content  文件内容
 */
+ (void)createFileWithFileName:(NSString *)FileName content:(NSString *)content{
    NSFileManager *manager = NSFileManager.defaultManager;
    [manager createFileAtPath:FileName contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

@end
