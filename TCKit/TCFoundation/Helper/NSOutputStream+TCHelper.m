//
//  NSOutputStream+TCHelper.m
//  TCFoundation
//
//  Created by cdk on 2017/12/15.
//  Copyright © 2017年 PixelCyber. All rights reserved.
//

#import "NSOutputStream+TCHelper.h"

@implementation NSOutputStream (TCHelper)

- (NSInteger)syncWrite:(const uint8_t *)buffer length:(NSUInteger)len
{
    NSUInteger size = len;
    NSUInteger writedSize = 0;
    do {
        NSInteger wSize = [self write:buffer+writedSize maxLength:size];
        if (wSize > 0) {
            writedSize += (NSUInteger)wSize;
            size -= (NSUInteger)wSize;
        }
        if (size < 1 || (wSize < 1 && !self.hasSpaceAvailable)) {
            return (NSInteger)writedSize;
        }
    } while (true);
}

@end


@implementation NSFileHandle (TCHelper)

- (nullable NSData *)tc_readDataToEndOfFileAndReturnError:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self readDataToEndOfFileAndReturnError:error];
    } else {
        return [self readDataToEndOfFile];
    }
}

- (nullable NSData *)tc_readDataUpToLength:(NSUInteger)length error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self readDataUpToLength:length error:error];
    } else {
        return [self readDataOfLength:length];
    }
}

- (BOOL)tc_writeData:(NSData *)data error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self writeData:data error:error];
    } else {
        [self writeData:data];
        return YES;
    }
}

- (BOOL)tc_getOffset:(out unsigned long long *)offsetInFile error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self getOffset:offsetInFile error:error];
    } else {
        if (NULL == offsetInFile) {
            return NO;
        }
        *offsetInFile = self.offsetInFile;
        return YES;
    }
}

- (BOOL)tc_seekToEndReturningOffset:(out unsigned long long *_Nullable)offsetInFile error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self seekToEndReturningOffset:offsetInFile error:error];
    } else {
        [self seekToEndOfFile];
        return YES;
    }
}

- (BOOL)tc_seekToOffset:(unsigned long long)offset error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self seekToOffset:offset error:error];
    } else {
        [self seekToFileOffset:offset];
        return YES;
    }
}

- (BOOL)tc_truncateAtOffset:(unsigned long long)offset error:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self truncateAtOffset:offset error:error];
    } else {
        [self truncateFileAtOffset:offset];
        return YES;
    }
}

- (BOOL)tc_synchronizeAndReturnError:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self synchronizeAndReturnError:error];
    } else {
        [self synchronizeFile];
        return YES;
        
    }
}

- (BOOL)tc_closeAndReturnError:(out NSError **)error
{
    if (@available(iOS 13, *)) {
        return [self closeAndReturnError:error];
    } else {
        [self closeFile];
        return YES;
    }
}

@end
