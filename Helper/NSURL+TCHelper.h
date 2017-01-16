//
//  NSURL+TCHelper.h
//  TCKit
//
//  Created by dake on 16/8/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (TCHelper)

- (nullable NSMutableDictionary<NSString *, NSString *> *)parseQueryToDictionary;
- (nullable instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force encodeQuering:(BOOL)encode;
- (nullable instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force;
- (nullable instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param;

- (unsigned long long)contentSizeInByte;

// xx.tar.gz -> tar.gz,
// xx.jpg?i=xx&j=oo -> jpg
- (nullable NSString *)fixedFileExtension;

@end

NS_ASSUME_NONNULL_END
