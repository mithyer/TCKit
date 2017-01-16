//
//  NSURL+TCHelper.m
//  TCKit
//
//  Created by dake on 16/8/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSURL+TCHelper.h"
#import "NSString+TCHelper.h"

@implementation NSURL (TCHelper)

- (nullable NSString *)fixedFileExtension
{
    if (self.pathExtension.length < 1) {
        return nil;
    }
    
    // xx.tar.gz
    NSString *ext = self.lastPathComponent;
    NSInteger const begin = [ext rangeOfString:@"."].location;
    if (begin == NSNotFound) {
        return nil;
    }
    ext = [ext substringFromIndex:begin + 1];
    
    // xx.jpg?i=xx&j=oo
    NSInteger const loc = [ext rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"&,;_-( )="]].location;
    if (loc != NSNotFound) {
        ext = [ext substringToIndex:loc];
    }
    
    return ext.length < 1 ? nil : ext;
}

- (NSCharacterSet *)urlComponentAllowedCharacters
{
    static NSCharacterSet *set = nil;
    if (nil == set) {
        set = [NSCharacterSet characterSetWithCharactersInString:@"/:?&=#%\x20"].invertedSet;
    }
    
    return set;
}

- (NSMutableDictionary *)parseQueryToDictionary
{
    return [self.query explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
}

- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force encodeQuering:(BOOL)encode
{
    if (param.count < 1) {
        return self;
    }
    
    // NSURLComponents auto url encoding, property auto decoding
    NSURLComponents *com = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    
    if (force) {
        NSMutableDictionary *dic = self.parseQueryToDictionary;
        if (nil == dic) {
            dic = NSMutableDictionary.dictionary;
        }
        [dic addEntriesFromDictionary:param];
        
        NSMutableString *query = NSMutableString.string;
        for (NSString *key in dic) {
            NSString *value = [NSString stringWithFormat:@"%@", dic[key]];
            if (encode) {
                value = [value stringByAddingPercentEncodingWithAllowedCharacters:self.urlComponentAllowedCharacters];
            }
            [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [key stringByAppendingFormat:@"=%@", value]];
        }
        com.query = query;
    } else {
        NSMutableString *query = NSMutableString.string;
        NSString *rawQuery = com.query;
        if (nil != rawQuery) {
            [query appendString:rawQuery];
        }
        
        for (NSString *key in param) {
            if (nil == com.query || [com.query rangeOfString:key].location == NSNotFound) {
                NSString *value = [NSString stringWithFormat:@"%@", param[key]];
                if (encode) {
                    value = [value stringByAddingPercentEncodingWithAllowedCharacters:self.urlComponentAllowedCharacters];
                }
                [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [key stringByAppendingFormat:@"=%@", value]];
            } else {
                NSAssert(false, @"conflict query param");
            }
        }
        com.query = query;
    }
    
    return com.URL;
}

- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force
{
    return [self appendParam:param override:force encodeQuering:NO];
}

- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param
{
    return [self appendParam:param override:NO];
}

- (unsigned long long)contentSizeInByte
{
    NSURL *url = self.filePathURL;
    if (nil == url) {
        return 0;
    }
    
    NSArray<NSString *> *subPath = [NSFileManager.defaultManager subpathsOfDirectoryAtPath:url.resourceSpecifier error:NULL];
    if (subPath.count > 0) {
        unsigned long long size = 0;
        for (NSString *fileName in subPath) {
            size += [self URLByAppendingPathComponent:fileName].contentSizeInByte;
        }
        return size;
    }
    
    return [NSFileManager.defaultManager attributesOfItemAtPath:url.resourceSpecifier error:NULL].fileSize;
}

@end
