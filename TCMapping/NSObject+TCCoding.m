//
//  NSObject+TCCoding.m
//  TCKit
//
//  Created by dake on 16/3/11.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSObject+TCCoding.h"
#import <objc/runtime.h>

#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIGeometry.h>
#import "TCMappingMeta.h"


typedef NS_ENUM(NSInteger, TCPersisentStyle) {
    kTCPersisentStylePlist = 0,
    kTCPersisentStyleJSON,
};


/**
 @brief	Get ISO date formatter.
 
 ISO8601 format example:
 2010-07-09T16:13:30+12:00
 2011-01-11T11:11:11+0000
 2011-01-26T19:06:43Z
 
 length: 20/24/25
 */
NS_INLINE NSDateFormatter *tcISODateFormatter(void) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    });
    return formatter;
}

NS_INLINE NSString *mappingForNSValue(NSValue *value)
{
    const char *type = value.objCType;
    if (strcmp(type, @encode(CGPoint)) == 0) {
        return NSStringFromCGPoint(value.CGPointValue);
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        return NSStringFromCGSize(value.CGSizeValue);
    } else if (strcmp(type, @encode(CGRect)) == 0) {
        return NSStringFromCGRect(value.CGRectValue);
    } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
        return NSStringFromUIEdgeInsets(value.UIEdgeInsetsValue);
    } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
        return NSStringFromCGAffineTransform(value.CGAffineTransformValue);
    } else if (strcmp(type, @encode(UIOffset)) == 0) {
        return NSStringFromUIOffset(value.UIOffsetValue);
    } else if (strcmp(type, @encode(NSRange)) == 0) {
        return NSStringFromRange(value.rangeValue);
    } else if (strcmp(type, @encode(CGVector)) == 0) {
        return NSStringFromCGVector(value.CGVectorValue);
    }
    
    return nil;
}

static NSObject *codingObject(NSObject *obj, TCPersisentStyle const style, Class parentKlass, TCMappingOption *option, NSMutableArray *recordFlag)
{
    if (nil == obj ||
        obj == (id)kCFNull ||
        [obj isKindOfClass:NSString.class] ||
        [obj isKindOfClass:NSNumber.class]) {
        if (kTCPersisentStylePlist == style && obj == (id)kCFNull) {
            return nil;
        }
        return obj;
    }
    
    if ([obj isMemberOfClass:NSObject.class] || [obj isMemberOfClass:NSProxy.class]) {
        return nil;
    }
    
    __unsafe_unretained Class curClass = obj.class;
    TCMappingOption *opt = option ?: ([curClass respondsToSelector:@selector(tc_mappingOption)] ? [curClass tc_mappingOption] : nil);
    BOOL emptyNil = nil != opt ? opt.codingEmptyDataToNil : YES;
    
    if ([obj isKindOfClass:NSDictionary.class]) {
        if (emptyNil && ((NSDictionary *)obj).count < 1) {
            return nil;
        }
        if (kTCPersisentStyleJSON == style && [NSJSONSerialization isValidJSONObject:obj]) {
            return obj;
        }
        
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        for (NSString *key in (NSDictionary *)obj) {
            NSString *strKey = [key isKindOfClass:NSString.class] ? key : key.description;
            if (strKey.length < 1) {
                continue;
            }
            NSObject *value = codingObject(((NSDictionary *)obj)[key], style, parentKlass, nil, recordFlag);
            if (nil != value) {
                dic[strKey] = value;
            }
        }
        return emptyNil ? (dic.count > 0 ? dic : nil) : dic;
        
    } else if ([obj isKindOfClass:NSArray.class]) {
        
        if (emptyNil && ((NSArray *)obj).count < 1) {
            return nil;
        }
        
        if (kTCPersisentStyleJSON == style && [NSJSONSerialization isValidJSONObject:obj]) {
            return obj;
        }
        
        NSMutableArray *arry = NSMutableArray.array;
        for (id value in (NSArray *)obj) {
            NSObject *jsonValue = codingObject(value, style, parentKlass, option, recordFlag);
            if (nil != jsonValue) {
                [arry addObject:jsonValue];
            }
        }
        return emptyNil ? (arry.count > 0 ? arry : nil) : arry;
        
    } else if ([obj isKindOfClass:NSSet.class]) { // -> array
        return codingObject(((NSSet *)obj).allObjects, style, parentKlass, option, recordFlag);
        
    } else if ([obj isKindOfClass:NSOrderedSet.class]) { // -> array
        return codingObject(((NSOrderedSet *)obj).array, style, parentKlass, option, recordFlag);
        
    } else if ([obj isKindOfClass:NSURL.class]) { // -> string
        return ((NSURL *)obj).absoluteString;
        
    } else if ([obj isKindOfClass:NSDate.class]) { // -> string
        if (kTCPersisentStylePlist == style) {
            return obj;
        }
        return [tcISODateFormatter() stringFromDate:(NSDate *)obj];
        
    } else if ([obj isKindOfClass:NSData.class]) { // -> Base64 string
        if (emptyNil && ((NSData *)obj).length < 1) {
            return nil;
        }
        
        if (kTCPersisentStylePlist == style) {
            return obj;
        }
        
        if ([parentKlass respondsToSelector:@selector(tc_transformHexStringFromData:)]) {
            return [parentKlass tc_transformHexStringFromData:(NSData *)obj];
        }
        return [(NSData *)obj base64EncodedStringWithOptions:kNilOptions];
        
    } else if ([obj isKindOfClass:UIColor.class]) { // -> string
        if ([parentKlass respondsToSelector:@selector(tc_transformHexStringFromColor:)]) {
            UIColor *color = (typeof(color))obj;
            return [parentKlass tc_transformHexStringFromColor:color];
        }
        return nil;
        
    } else if ([obj isKindOfClass:UIImage.class]) { // -> data
        if ([parentKlass respondsToSelector:@selector(tc_transformDataFromImage:)]) {
            return codingObject([parentKlass tc_transformDataFromImage:(UIImage *)obj], style, parentKlass, nil, recordFlag);
        }
        return nil;
        
    } else if ([obj isKindOfClass:NSAttributedString.class]) { // -> string
        return ((NSAttributedString *)obj).string;
        
    } else if ([obj isKindOfClass:NSValue.class]) { // -> Base64 string
        return mappingForNSValue((NSValue *)obj);
        
    } else if (class_isMetaClass(object_getClass(obj))) { // -> string
        return NSStringFromClass((Class)obj);
        
    } else { // user defined class
        BOOL isNSNullValid = opt.shouldCodingNSNull;
        NSDictionary<NSString *, id> *nameDic = opt.nameCodingMapping;
        __unsafe_unretained NSDictionary<NSString *, TCMappingMeta *> *metaDic = tc_propertiesUntilRootClass(curClass, nil != option ? option.autoMapUntilRoot : YES);
        NSMutableDictionary *dic = NSMutableDictionary.dictionary;
        
        NSMutableArray *record = recordFlag ?: NSMutableArray.array;
        for (NSString *key in metaDic) {
            __unsafe_unretained TCMappingMeta *meta = metaDic[key];
            if (NULL == meta->_getter ||
                tc_ignoreCodingForInfo(meta->_info) ||
                nameDic[key] == (id)kCFNull ||
                tc_typeForInfo(meta->_info) == kTCEncodingTypeBlock) {
                continue;
            }
            
            NSObject *value = [obj valueForKey:NSStringFromSelector(meta->_getter) meta:meta ignoreNSNull:!isNSNullValid];
            if (value == obj || NSNotFound != [record indexOfObjectIdenticalTo:value]) {
                continue;
            }
            
            
            if (nil == value && isNSNullValid) {
                value = (typeof(value))kCFNull;
            }
            
            if (nil != value && (typeof(value))kCFNull != value && tc_isObjForInfo(meta->_info)) {
                [record addObject:value];
            }
            
            TCMappingOption *propOpt = nil;
            if ([nameDic[key] isKindOfClass:TCMappingOption.class]) {
                propOpt = (typeof(propOpt))nameDic[key];
            }
            
            if (nil != value) {
                value = codingObject(value, style, curClass, propOpt, record);
            }
            
            if (nil != value) {
                dic[nil == propOpt ? (nameDic[key] ?: key) : key] = value;
            }
        }
        
        return dic.count > 0 ? dic : nil;
    }
    
    return nil;
}


@implementation NSObject (TCCoding)

- (id)tc_JSONObject
{
    return [self tc_JSONObjectWithOption:nil];
}

- (id)tc_JSONObjectWithOption:(TCMappingOption * __nullable)option
{
    NSObject *obj = codingObject(self, kTCPersisentStyleJSON, Nil, option, nil);
    if (nil == obj || [obj isKindOfClass:NSArray.class] || [obj isKindOfClass:NSDictionary.class]) {
        return obj;
    }
    return nil;
}

- (NSData *)tc_JSONData
{
    id obj = self.tc_JSONObject;
    return nil != obj ? [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:NULL] : nil;
}

- (NSString *)tc_JSONString
{
    NSData *data = self.tc_JSONData;
    if (nil == data || data.length < 1) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (BOOL)tc_writeJSONToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    NSParameterAssert(path);
    if (path.length < 1) {
        return NO;
    }
    
    return [self.tc_JSONString writeToFile:path atomically:useAuxiliaryFile encoding:NSUTF8StringEncoding error:NULL];
}


#pragma mark - TCPlistMapping

- (id)tc_plistObject
{
    NSObject *obj = codingObject(self, kTCPersisentStylePlist, Nil, nil, nil);
    if (nil == obj ||
        [obj isKindOfClass:NSString.class] ||
        [obj isKindOfClass:NSNumber.class] ||
        [obj isKindOfClass:NSArray.class] ||
        [obj isKindOfClass:NSDictionary.class] ||
        [obj isKindOfClass:NSData.class] ||
        [obj isKindOfClass:NSDate.class]) {
        return obj;
    }
    return nil;
}


@end


@implementation NSString (TCJSONMapping)

- (id)tc_JSONObject
{
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
}

@end


@implementation NSData (TCJSONMapping)

- (id)tc_JSONObject
{
    return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:NULL];
}

@end
