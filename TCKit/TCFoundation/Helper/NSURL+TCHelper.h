//
//  NSURL+TCHelper.h
//  TCKit
//
//  Created by dake on 16/8/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * TCPercentEscapedStringFromString(NSString *string);

@interface NSURL (TCHelper)

- (nullable NSMutableDictionary<NSString *, NSString *> *)parseQueryToDictionary; // decodeInf: YES
- (nullable NSMutableDictionary<NSString *, NSString *> *)parseQueryToDictionaryWithDecodeInf:(BOOL)decodeInf;
- (nullable instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force encodeQuering:(BOOL)encode;
- (nullable instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force;
- (nullable instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param;

- (unsigned long long)contentSizeInByte;

// xx.tar.gz -> tar.gz,
// xx.jpg?i=xx&j=oo -> jpg
- (nullable NSString *)fixedFileExtension;

- (nullable NSString *)tc_fileMD5;

@end

@interface NSCharacterSet (TCHelper)

+ (NSCharacterSet *)urlComponentAllowedCharacters;

@end

NS_ASSUME_NONNULL_END
