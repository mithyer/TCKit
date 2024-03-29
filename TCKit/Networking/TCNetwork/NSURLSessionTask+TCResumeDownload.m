//
//  NSURLSessionTask+TCResumeDownload.m
//  TCKit
//
//  Created by dake on 16/1/9.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSURLSessionTask+TCResumeDownload.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

#ifndef __TCKit__
#import <CoreGraphics/CGGeometry.h>
#import <CoreGraphics/CGAffineTransform.h>
#import <UIKit/UIGeometry.h>
#endif


static NSString *const kNSURLSessionResumeInfoTempFileName = @"NSURLSessionResumeInfoTempFileName";
static NSString *const kNSURLSessionResumeInfoLocalPath = @"NSURLSessionResumeInfoLocalPath";


static NSString *tc_md5_32(NSString *str)
{
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
}


@implementation NSObject (TCResumeDownload)

- (BOOL)tc_makePersistentResumeCapable
{
    if (![self isKindOfClass:NSURLSessionDownloadTask.class] ||
        ![self respondsToSelector:@selector(cancelByProducingResumeData:)]) {
        return NO;
    }
    
    static NSMutableSet *enabledClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        enabledClasses = NSMutableSet.set;
    });
    
    @synchronized(enabledClasses) {
        Class klass = self.class;
        if (![enabledClasses containsObject:klass]) {
            [klass tc_swizzle:@selector(cancelByProducingResumeData:)];
            [enabledClasses addObject:klass];
        }
    }
    
    return YES;
}

- (NSString *)tc_resumeIdentifier
{
    NSString *identifier = objc_getAssociatedObject(self, _cmd);
    if (identifier.length < 1) {
        identifier = tc_md5_32(((NSURLSessionTask *)self).originalRequest.URL.absoluteString);
        if (identifier.length > 0) {
            [self setTc_resumeIdentifier:identifier];
        }
    }
    return identifier;
}

- (void)setTc_resumeIdentifier:(NSString *)tc_resumeIdentifier
{
    objc_setAssociatedObject(self, @selector(tc_resumeIdentifier), tc_resumeIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tc_resumeCacheDirectory
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTc_resumeCacheDirectory:(NSString *)tc_resumeCacheDirectory
{
    objc_setAssociatedObject(self, @selector(tc_resumeCacheDirectory), tc_resumeCacheDirectory, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)tc_purgeResumeData
{
    [NSURLSessionTask tc_purgeResumeDataWithIdentifier:self.tc_resumeIdentifier inDirectory:self.tc_resumeCacheDirectory];
}

- (void)tc_cancelByProducingResumeData:(void (^)(NSData * __nullable resumeData))completionHandler
{
    if (self.tc_resumeCacheDirectory.length < 1) {
        [self tc_cancelByProducingResumeData:completionHandler];
        return;
    }
    
    __weak typeof(self) wSelf = self;
    [self tc_cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        __strong typeof(wSelf) sSelf = wSelf;
        dispatch_block_t block = ^{
            if (nil != resumeData) {
                @autoreleasepool {
                    if ([resumeData writeToFile:sSelf.tc_resumeCachePath atomically:YES] &&
                        ![NSURLSessionTask tc_isTmpResumeCache:sSelf.tc_resumeCacheDirectory]) {
                        NSString *tmpDownloadFile = [sSelf.class tc_resumeInfoTempFileNameFor:resumeData];
                        if (nil != tmpDownloadFile) {
                            NSError *error = nil;
                            NSString *cachePath = [sSelf.tc_resumeCacheDirectory stringByAppendingPathComponent:tmpDownloadFile.lastPathComponent];
                            [NSFileManager.defaultManager removeItemAtPath:cachePath error:NULL];
                            [NSFileManager.defaultManager moveItemAtPath:tmpDownloadFile toPath:cachePath error:&error];
                            NSCAssert(nil == error, @"%@", error);
                        }
                    }
                }
            }
            
            if (nil != completionHandler) {
                completionHandler(resumeData);
            }
        };
        
        if (NSThread.isMainThread) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
        } else {
            block();
        }
    }];
}


#pragma mark -

+ (NSString *)tc_resumeInfoTempFileNameFor:(NSData *)data
{
    if (nil == data) {
        return nil;
    }
    
    NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
    NSString *fileName = nil;
    if (nil != dic) {
        fileName = dic[kNSURLSessionResumeInfoTempFileName];
        if (nil == fileName) {
            fileName = [dic[kNSURLSessionResumeInfoLocalPath] lastPathComponent];
        }
        
        if (nil != fileName) {
            fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        }
    }
    
    return fileName;
}

+ (NSString *)tc_resumeCachePathWithDirectory:(NSString *)subpath identifier:(NSString *)indentifier
{
    return [subpath stringByAppendingPathComponent:tc_md5_32(indentifier)];
}

+ (BOOL)tc_isTmpResumeCache:(NSString *)resumeDirectory
{
    return [resumeDirectory hasPrefix:NSTemporaryDirectory()];
}

- (NSString *)tc_resumeCachePath
{
    return [self.class tc_resumeCachePathWithDirectory:self.tc_resumeCacheDirectory identifier:self.tc_resumeIdentifier];
}


#ifndef __TCKit__
#pragma mark - helper

+ (BOOL)tc_swizzle:(SEL)aSelector
{
    Method m1 = class_getInstanceMethod(self, aSelector);
    if (NULL == m1) {
        return NO;
    }
    
    SEL bSelector = NSSelectorFromString([NSString stringWithFormat:@"tc_%@", NSStringFromSelector(aSelector)]);
    Method m2 = class_getInstanceMethod(self, bSelector);

    if (class_addMethod(self, aSelector, method_getImplementation(m2), method_getTypeEncoding(m2))) {
        class_replaceMethod(self, bSelector, method_getImplementation(m1), method_getTypeEncoding(m1));
    } else {
        method_exchangeImplementations(m1, m2);
    }
    
    return YES;
}
#endif

@end


#pragma mark - NSURLSessionTask

@implementation NSURLSessionTask (TCResumeDownload)

- (BOOL)tc_makePersistentResumeCapable
{
    return [super tc_makePersistentResumeCapable];
}

- (NSString *)tc_resumeIdentifier
{
    return [super tc_resumeIdentifier];
}

- (void)setTc_resumeIdentifier:(NSString *)tc_resumeIdentifier
{
    [super setTc_resumeIdentifier:tc_resumeIdentifier];
}

- (NSString *)tc_resumeCacheDirectory
{
    return [super tc_resumeCacheDirectory];
}

- (void)setTc_resumeCacheDirectory:(NSString *)tc_resumeCacheDirectory
{
    [super setTc_resumeCacheDirectory:tc_resumeCacheDirectory];
}


#pragma mark -

+ (nullable NSData *)tc_resumeDataWithIdentifier:(NSString *)identifier inDirectory:(nullable NSString *)subpath
{
    NSData *data = [NSData dataWithContentsOfFile:[self tc_resumeCachePathWithDirectory:subpath identifier:identifier] options:NSDataReadingUncached|NSDataReadingMappedAlways error:NULL];
    NSString *tmpDownloadFile = [self tc_resumeInfoTempFileNameFor:data];
    if (nil != tmpDownloadFile) {
        if (![self tc_isTmpResumeCache:subpath]) {
            NSError *error = nil;
            [NSFileManager.defaultManager removeItemAtPath:tmpDownloadFile error:NULL];
            [NSFileManager.defaultManager copyItemAtPath:[subpath stringByAppendingPathComponent:tmpDownloadFile.lastPathComponent] toPath:tmpDownloadFile error:&error];
            NSAssert(nil == error, @"%@", error);
        }
        
        if (![NSFileManager.defaultManager fileExistsAtPath:tmpDownloadFile]) {
            if (nil != subpath) {
                [NSFileManager.defaultManager removeItemAtPath:[subpath stringByAppendingPathComponent:tmpDownloadFile.lastPathComponent] error:NULL];
            }
            data = nil;
        }
    }
    
    return data;
}

+ (void)tc_purgeResumeDataWithIdentifier:(NSString *)identifier inDirectory:(nullable NSString *)subpath
{
    NSString *path = [self tc_resumeCachePathWithDirectory:subpath identifier:identifier];
    
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return;
    }
    
    // rm tmp files
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached|NSDataReadingMappedAlways error:NULL];
    NSString *tmpDownloadFile = [self tc_resumeInfoTempFileNameFor:data];
    if (nil != tmpDownloadFile) {
        [NSFileManager.defaultManager removeItemAtPath:tmpDownloadFile error:NULL];
        
        if (nil != subpath) {
            [NSFileManager.defaultManager removeItemAtPath:[subpath stringByAppendingPathComponent:tmpDownloadFile.lastPathComponent] error:NULL];
        }
    }
    
    [NSFileManager.defaultManager removeItemAtPath:path error:NULL];
}

- (void)tc_purgeResumeData
{
    [super tc_purgeResumeData];
}

@end


