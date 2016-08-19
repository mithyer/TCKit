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

@end
