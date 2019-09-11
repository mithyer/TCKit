//
//  NSObject+TCHelper.h
//  TCKit
//
//  Created by dake on 14-5-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern size_t _TCEndian_readf(FILE *stream, const char *format, ...);

@interface NSObject (TCHelper)

@property (nullable, nonatomic, copy) NSString *humanDescription;

// file system
+ (nullable NSURL *)defaultPersistentDirectoryInDomain:(NSString *__nullable)domain create:(BOOL)create;
+ (nullable NSURL *)defaultCacheDirectoryInDomain:(NSString *__nullable)domain create:(BOOL)create;
+ (nullable NSURL *)defaultTmpDirectoryInDomain:(NSString *__nullable)domain create:(BOOL)create;

@end

@interface NSJSONSerialization (TCHelper)

@end

NS_ASSUME_NONNULL_END
