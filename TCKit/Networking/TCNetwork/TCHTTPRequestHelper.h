//
//  TCHTTPRequestHelper.h
//  TCKit
//
//  Created by dake on 15/3/15.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCHTTPRequestHelper : NSObject

+ (nullable NSString *)MD5_32:(NSString *)str;
+ (nullable NSString *)MD5_16:(NSString *)str;

@end


#ifndef __TCKit__

@interface NSURL (TCHTTPRequestHelper)

- (NSURL *)appendParamIfNeed:(NSDictionary<NSString *, id> *)param orderKey:(NSArray<NSString *> *)orderKey;

@end

@interface NSURL (IDN)

+ (NSString *)IDNEncodedHostname:(NSString *)aHostname;
+ (NSString *)IDNDecodedHostname:(NSString *)anIDNHostname;
+ (NSString *)IDNEncodedURL:(NSString *)aURL;
+ (NSString *)IDNDecodedURL:(NSString *)anIDNURL;

@end

#endif // __TCKit__

NS_ASSUME_NONNULL_END
