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

- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param
{
    if (param.count < 1) {
        return self;
    }
    
    // NSURLComponents 自带 url encoding, property 自动 decoding
    NSURLComponents *com = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
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
    
    return com.URL;
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
