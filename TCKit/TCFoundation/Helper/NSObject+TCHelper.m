//
//  NSObject+TCHelper.m
//  TCKit
//
//  Created by dake on 14-5-4.
//  Copyright (c) 2014年 dake. All rights reserved.
//

#import "NSObject+TCHelper.h"
#import <objc/runtime.h>

static NSString const *kDefaultDomain = @"TCKit";

@implementation NSObject (TCHelper)

@dynamic humanDescription;

+ (NSString *)defaultPersistentDirectoryInDomain:(NSString *)domain
{
    return [self defaultPersistentDirectoryInDomain:domain create:YES];
}

+ (NSString *)defaultPersistentDirectoryInDomain:(NSString *)domain create:(BOOL)create
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:domain?:kDefaultDomain];
    //#if TARGET_IPHONE_SIMULATOR
    //    path = [path stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    //#endif
    
    if (create && ![NSFileManager.defaultManager createDirectoryAtPath:dir
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL]) {
        NSAssert(false, @"create directory failed.");
        dir = nil;
    }
    
    return dir;
}

+ (NSString *)defaultCacheDirectoryInDomain:(NSString *)domain
{
    return [self defaultCacheDirectoryInDomain:domain create:YES];
}

+ (NSString *)defaultCacheDirectoryInDomain:(NSString *)domain create:(BOOL)create
{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:domain?:kDefaultDomain];
    
    if (create && ![NSFileManager.defaultManager createDirectoryAtPath:dir
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL]) {
        NSAssert(false, @"create directory failed.");
        dir = nil;
    }
    return dir;
}

+ (NSString *)defaultTmpDirectoryInDomain:(NSString *)domain
{
    return [self defaultTmpDirectoryInDomain:domain create:YES];
}

+ (NSString *)defaultTmpDirectoryInDomain:(NSString *)domain create:(BOOL)create;
{
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:domain?:kDefaultDomain];
    if (create && ![NSFileManager.defaultManager createDirectoryAtPath:dir
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:NULL]) {
        NSAssert(false, @"create directory failed.");
        dir = nil;
    }
    
    return dir;
}


+ (NSString *)humanDescription
{
    return nil;
}

- (NSString *)humanDescription
{
    NSString *str = objc_getAssociatedObject(self, @selector(setHumanDescription:));
    return str ?: self.class.humanDescription;
}

- (void)setHumanDescription:(NSString *)humanDescription
{
    objc_setAssociatedObject(self, _cmd, humanDescription, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


@end
