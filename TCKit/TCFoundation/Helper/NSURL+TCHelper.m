//
//  NSURL+TCHelper.m
//  TCKit
//
//  Created by dake on 16/8/19.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSURL+TCHelper.h"
#import "NSString+TCHelper.h"
#import <CommonCrypto/CommonCrypto.h>

NSString * TCPercentEscapedStringFromString(NSString *string) {
    NSCharacterSet *allowedCharacterSet = NSCharacterSet.urlComponentAllowedCharacters;
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = NSMutableString.string;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

NSString * TCPercentEscapedStringFromFileName(NSString *string)
{
    if (string.length < 1) {
        return string;
    }
    
    NSString *name = [[string componentsSeparatedByCharactersInSet:NSCharacterSet.illegalFileNameCharacters] componentsJoinedByString:@"_"];
    if (name.length > NAME_MAX) {
        name = [name substringFromIndex:name.length - NAME_MAX];
    } else if ([name isEqualToString:@"_"]) {
        name = @"";
    }
    return name;
}

@implementation NSCharacterSet (TCHelper)

//+ (NSCharacterSet *) chineseAndEngSet
//{
//    static NSCharacterSet *chineseNameSet;
//    if (chineseNameSet == nil)
//    {
//        NSMutableCharacterSet *aCharacterSet = [[NSMutableCharacterSet alloc] init];
//
//        NSRange lcEnglishRange;
//        lcEnglishRange.location = (unsigned int)0x4e00;
//        lcEnglishRange.length = (unsigned int)0x9fa5 - (unsigned int)0x4e00;
//        [aCharacterSet addCharactersInRange:lcEnglishRange];
//        [aCharacterSet addCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
//        chineseNameSet = aCharacterSet;
//    }
//    return chineseNameSet;
//}

+ (NSCharacterSet *)urlComponentAllowedCharacters
{
    static NSString *const kTCCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString *const kTCCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *allowedCharacterSet = NSCharacterSet.URLHostAllowedCharacterSet.mutableCopy;
        [allowedCharacterSet removeCharactersInString:[kTCCharactersGeneralDelimitersToEncode stringByAppendingString:kTCCharactersSubDelimitersToEncode]];
        set = allowedCharacterSet;
    });
    
    return set;
}

+ (NSCharacterSet *)illegalFileNameCharacters
{
    static NSCharacterSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *notAllowedCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
        set = notAllowedCharacterSet;
    });
    
    return set;
}

@end

@implementation NSURL (TCHelper)

- (NSURL *)safeURLByResolvingSymlinksInPath
{
    NSURL *url = self.URLByResolvingSymlinksInPath;
    if (nil == url || [url isEqual:self]) {
        return self;
    }
    
    return url;
}

- (nullable instancetype)URLByAppendingPathExtensionMust:(NSString *)str
{
    if (nil == str || str.length < 1) {
        return self;
    }
    
    NSURL *tmp = [self URLByAppendingPathExtension:str];
    if (nil != tmp) {
        return tmp;
    }
    
    NSString *fileName = self.lastPathComponent;
    return [self.URLByDeletingLastPathComponent URLByAppendingPathComponent:[fileName stringByAppendingFormat:@".%@", str]];
}

- (nullable NSString *)fixedFileExtension
{
    return self.absoluteString.fixedFileExtension;
}

- (nullable NSString *)fixedPath
{
    return (self.hasDirectoryPath && self.path.length > 1) ? [self.path stringByAppendingString:@"/"] : self.path;
}

- (nullable NSMutableDictionary<NSString *, NSString *> *)parseQueryToDictionaryWithDecodeInf:(BOOL)decodeInf
{
    NSString *query = [self.query stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    return [query explodeToDictionaryInnerGlue:@"=" outterGlue:@"&" decodeInf:decodeInf];
}

- (NSMutableDictionary *)parseQueryToDictionary
{
    NSString *query = [self.query stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    return [query explodeToDictionaryInnerGlue:@"=" outterGlue:@"&" decodeInf:YES];
}

- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force encodeQuering:(BOOL)encode
{
    if (param.count < 1) {
        return self;
    }
    
    // NSURLComponents auto url encoding, property auto decoding
    NSURLComponents *com = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    
    if (force) {
        NSMutableDictionary *dic = [self parseQueryToDictionaryWithDecodeInf:NO];
        if (nil == dic) {
            dic = NSMutableDictionary.dictionary;
        }
        [dic addEntriesFromDictionary:param];
        
        NSMutableString *query = NSMutableString.string;
        for (NSString *key in dic) {
            NSString *value = TCPercentEscapedStringFromString([NSString stringWithFormat:@"%@", dic[key]]);
            if (encode) {
                value = TCPercentEscapedStringFromString(value);
            }
            [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [TCPercentEscapedStringFromString(key) stringByAppendingFormat:@"=%@", value]];
        }
        com.percentEncodedQuery = query;
    } else {
        NSMutableString *query = NSMutableString.string;
        NSString *rawQuery = com.percentEncodedQuery;
        if (rawQuery.length > 0) {
            [query appendString:rawQuery];
        }
        
        for (NSString *key in param) {
            if (nil == com.percentEncodedQuery || [com.percentEncodedQuery rangeOfString:key].location == NSNotFound) {
                NSString *value = TCPercentEscapedStringFromString([NSString stringWithFormat:@"%@", param[key]]);
                if (encode) {
                    value = TCPercentEscapedStringFromString(value);
                }
                [query appendFormat:(query.length > 0 ? @"&%@" : @"%@"), [TCPercentEscapedStringFromString(key) stringByAppendingFormat:@"=%@", value]];
            } else {
                NSAssert(false, @"conflict query param");
            }
        }
        com.percentEncodedQuery = query;
    }
    
    return com.URL;
}

- (instancetype)appendParam:(NSDictionary<NSString *, id> *)param override:(BOOL)force
{
    return [self appendParam:param override:force encodeQuering:NO];
}

- (instancetype)appendParamIfNeed:(NSDictionary<NSString *, id> *)param
{
    return [self appendParam:param override:NO];
}

- (unsigned long long)contentSizeInByte
{
    if (!self.isFileURL) {
        return 0;
    }
    
    NSURL *url = self.safeURLByResolvingSymlinksInPath;
    NSArray<NSString *> *subPath = [NSFileManager.defaultManager subpathsOfDirectoryAtPath:url.path error:NULL];
    if (subPath.count > 0) {
        unsigned long long size = 0;
        for (NSString *fileName in subPath) {
            size += [url URLByAppendingPathComponent:fileName].contentSizeInByte;
        }
        return size;
    }
    
    return [NSFileManager.defaultManager attributesOfItemAtPath:url.path error:NULL].fileSize;
}


#pragma mark -

// http://siruoxian.iteye.com/blog/2013601
// http://www.cnblogs.com/visen-0/p/3160907.html

#define FileHashDefaultChunkSizeForReadingData 1024*8
static CFStringRef FileMD5HashCreateWithPath(CFURLRef fileURL,
                                             size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (chunkSizeForReadingData < 1) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    return result;
}

- (NSString *)tc_fileMD5
{
    if (!self.isFileURL || self.hasDirectoryPath) {
        return nil;
    }
    NSURL *url = self.safeURLByResolvingSymlinksInPath;
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFURLRef)url, FileHashDefaultChunkSizeForReadingData);
}

@end
