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

- (NSMutableDictionary *)parseQueryToDictionary
{
    return [self.query explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
}

- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force
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
            [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [key stringByAppendingFormat:@"=%@", dic[key]]];
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
                [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [key stringByAppendingFormat:@"=%@", param[key]]];
            } else {
                NSAssert(false, @"conflict query param");
            }
        }
        com.query = query;
    }
    
    return com.URL;
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
