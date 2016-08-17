//
//  TCHTTPRequestHelper.m
//  TCKit
//
//  Created by dake on 15/3/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "TCHTTPRequestHelper.h"

#ifndef __TCKit__
#import <CommonCrypto/CommonDigest.h>
#endif


@implementation TCHTTPRequestHelper

+ (NSString *)urlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters
{
    NSString *url = originUrlString;
    NSString *paraUrlString = parameters.convertToHttpQuery;
    
    if (nil != paraUrlString && paraUrlString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            url = [originUrlString stringByAppendingString:paraUrlString];
        } else {
            url = [originUrlString stringByAppendingFormat:@"?%@", [paraUrlString substringFromIndex:1]];
        }
    }
    
    return url;
}


#pragma mark - MD5

+ (NSString *)MD5_32:(NSString *)str
{
#ifndef __TCKit__
    if (str.length < 1) {
        return nil;
    }
    
    const char *value = str.UTF8String;
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; ++count) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
#else
    return str.MD5_32;
#endif
}

+ (NSString *)MD5_16:(NSString *)str
{
#ifndef __TCKit__
    NSString *value = [self MD5_32:str];
    return nil != value ? [value substringWithRange:NSMakeRange(8, 16)] : value;
#else
    return str.MD5_16;
#endif
}


@end


@implementation NSDictionary (TCHTTPRequestHelper)

- (NSString *)convertToHttpQuery
{
    NSMutableString *queryString = nil;
    if (self.count > 0) {
        queryString = NSMutableString.string;
        for (NSString *key in self) {
            NSString *value = self[key];
            if (nil != value) {
                [queryString appendFormat:queryString.length > 0 ? @"&%@=%@" : @"%@=%@", key, value];
            }
        }
    }
    return [queryString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

@end


@implementation NSURL (TCHTTPRequestHelper)

- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param
{
    if (param.count < 1) {
        return self;
    }
    
    NSURLComponents *com = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableString *query = [NSMutableString string];
    NSString *rawQuery = com.query.stringByRemovingPercentEncoding;
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
    com.query = [query stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    
    return com.URL;
}

@end