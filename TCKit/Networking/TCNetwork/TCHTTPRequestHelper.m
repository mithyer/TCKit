//
//  TCHTTPRequestHelper.m
//  TCKit
//
//  Created by dake on 15/3/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "TCHTTPRequestHelper.h"
#import "AFURLRequestSerialization.h"

#ifndef __TCKit__
#import <CommonCrypto/CommonDigest.h>
#endif


@implementation TCHTTPRequestHelper


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


#ifndef __TCKit__

@implementation NSURL (TCHTTPRequestHelper)

- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param
{
    if (param.count < 1) {
        return self;
    }
    
    // NSURLComponents auto url encoding, property auto decoding
    NSURLComponents *com = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableString *query = NSMutableString.string;
    NSString *rawQuery = com.percentEncodedQuery;
    if (rawQuery.length > 0) {
        [query appendString:rawQuery];
    }
    
    for (NSString *key in param) {
        if (nil == com.percentEncodedQuery || [com.percentEncodedQuery rangeOfString:key].location == NSNotFound) {
            [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [AFPercentEscapedStringFromString(key) stringByAppendingFormat:@"=%@", AFPercentEscapedStringFromString([NSString stringWithFormat:@"%@", param[key]])]];
        } else {
            NSAssert(false, @"conflict query param");
        }
    }
    com.percentEncodedQuery = query;
    
    return com.URL;
}

@end

#endif // __TCKit__
