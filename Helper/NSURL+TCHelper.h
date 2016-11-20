//
//  NSURL+TCHelper.h
//  TCKit
//
//  Created by dake on 16/8/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (TCHelper)

- (NSMutableDictionary<NSString *, NSString *> *)parseQueryToDictionary;
- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force encodeQuering:(BOOL)encode;
- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force;
- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param;

- (unsigned long long)contentSizeInByte;

@end
