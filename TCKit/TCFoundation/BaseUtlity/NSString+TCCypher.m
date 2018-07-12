//
//  NSString+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSString+TCCypher.h"
#import "NSData+TCCypher.h"
#import <zlib.h>


#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSString (TCCypher)


#pragma mark - AES

- (nullable NSData *)AESEncryptWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] cryptoOperation:kCCEncrypt algorithm:kCCAlgorithmAES option:kCCOptionPKCS7Padding key:key iv:iv keySize:keySize error:NULL];
}

- (nullable NSData *)AESDecryptBase64WithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters] cryptoOperation:kCCDecrypt algorithm:kCCAlgorithmAES option:kCCOptionPKCS7Padding key:key iv:iv keySize:keySize error:NULL];
}

- (nullable NSData *)AESDecryptHexWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[NSData dataWithHexString:self] cryptoOperation:kCCDecrypt algorithm:kCCAlgorithmAES option:kCCOptionPKCS7Padding key:key iv:iv keySize:keySize error:NULL];
}


#pragma mark - MD5

- (NSString *)MD5_32
{
    if (self.length < 1) {
        return nil;
    }
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    const char *input = self.UTF8String;
    CC_MD5(input, (CC_LONG)strlen(input), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [outputString appendFormat:@"%02x", outputBuffer[i]];
    }
    
    return outputString;
}

- (NSString *)MD5_16
{
    NSString *str = self.MD5_32;
    return nil != str ? [str substringWithRange:NSMakeRange(8, 16)] : str;
}

- (NSString *)MD4
{
    if (self.length < 1) {
        return nil;
    }
    
    unsigned char outputBuffer[CC_MD4_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    const char *input = self.UTF8String;
    CC_MD4(input, (CC_LONG)strlen(input), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD4_DIGEST_LENGTH * 2];
    for (NSUInteger i = 0; i < CC_MD4_DIGEST_LENGTH; ++i) {
        [outputString appendFormat:@"%02x", outputBuffer[i]];
    }
    
    return outputString;
}

- (NSString *)MD2
{
    if (self.length < 1) {
        return nil;
    }
    
    unsigned char outputBuffer[CC_MD2_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    const char *input = self.UTF8String;
    CC_MD2(input, (CC_LONG)strlen(input), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD2_DIGEST_LENGTH * 2];
    for (NSUInteger i = 0; i < CC_MD2_DIGEST_LENGTH; ++i) {
        [outputString appendFormat:@"%02x", outputBuffer[i]];
    }
    
    return outputString;
}

// https://stackoverflow.com/questions/39005351/zlib-seems-to-be-returning-crc32b-not-crc32-in-c
- (unsigned long)CRC32B
{
    if (self.length < 1) {
        return 0;
    }
    const char *input = self.UTF8String;
    uLong crc = crc32(0L, Z_NULL, 0);
    return crc32(crc, (const Bytef *)input, (uInt)strlen(input));
}

- (nullable NSString *)CRC32BString
{
    if (self.length < 1) {
        return nil;
    }
    const char *input = self.UTF8String;
    uLong crc = crc32(0L, Z_NULL, 0);
    uLong c = crc32(crc, (const Bytef *)input, (uInt)strlen(input));
    return [NSString stringWithFormat:@"%08lx", c];;
}

- (uint32_t)CRC32
{
    if (self.length < 1) {
        return 0U;
    }
    const char *input = self.UTF8String;
    return tc_crc32_formula_reflect(strlen(input), (const unsigned char *)input);
}

- (nullable NSString *)CRC32String
{
    return [NSString stringWithFormat:@"%08x", self.CRC32];
}

- (unsigned long)adler32
{
    if (self.length < 1) {
        return 0;
    }
    
    const char *input = self.UTF8String;
    uLong crc = adler32(0L, Z_NULL, 0);
    return adler32(crc, (const Bytef *)input, (uInt)strlen(input));
}

- (nullable NSString *)adler32String
{
    if (self.length < 1) {
        return nil;
    }
    
    const char *input = self.UTF8String;
    uLong crc = adler32(0L, Z_NULL, 0);
    uLong c = adler32(crc, (const Bytef *)input, (uInt)strlen(input));
    return [NSString stringWithFormat:@"%08lx", c];
}


- (NSString *)SHAString:(NSUInteger)len
{
    unsigned char result[len];
    const char *input = self.UTF8String;
    switch (len) {
        case CC_SHA1_DIGEST_LENGTH:
            CC_SHA1(input, (CC_LONG)strlen(input), result);
            break;
            
        case CC_SHA256_DIGEST_LENGTH:
            CC_SHA256(input, (CC_LONG)strlen(input), result);
            break;
            
        case CC_SHA224_DIGEST_LENGTH:
            CC_SHA224(input, (CC_LONG)strlen(input), result);
            break;
            
        case CC_SHA384_DIGEST_LENGTH:
            CC_SHA384(input, (CC_LONG)strlen(input), result);
            break;
            
        case CC_SHA512_DIGEST_LENGTH:
            CC_SHA512(input, (CC_LONG)strlen(input), result);
            break;
            
        default:
            return nil;
    }
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:len * 2];
    for (NSUInteger i = 0; i < len; ++i) {
        [outputString appendFormat:@"%02x", result[i]];
    }
    return outputString;
}

- (nullable NSString *)Hmac:(CCHmacAlgorithm)alg key:(nullable NSData *)key
{
    NSUInteger digestLen = 0;
    switch (alg) {
        case kCCHmacAlgSHA1:
            digestLen = CC_SHA1_DIGEST_LENGTH;
            break;
        case kCCHmacAlgMD5:
            digestLen = CC_MD5_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA224:
            digestLen = CC_SHA224_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA256:
            digestLen = CC_SHA256_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA384:
            digestLen = CC_SHA384_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA512:
            digestLen = CC_SHA512_DIGEST_LENGTH;
            break;
        default:
            return nil;
    }
    
    unsigned char buf[digestLen];
    const char *input = self.UTF8String;
    CCHmac(alg, key.bytes, key.length, input, strlen(input), buf);
    NSMutableString *outputString = [NSMutableString stringWithCapacity:digestLen * 2];
    for (NSUInteger i = 0; i < digestLen; ++i) {
        [outputString appendFormat:@"%02x", buf[i]];
    }
    return outputString;
}

- (NSString *)base64Encode
{
    return  [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

- (NSString *)base64Decode
{
    return [self base64DecodeWithOptions:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)base64DecodeWithOptions:(NSDataBase64DecodingOptions)options
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:options];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (nullable NSData *)base64DecodeData
{
    return [self base64DecodeDataWithOptions:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (nullable NSData *)base64DecodeDataWithOptions:(NSDataBase64DecodingOptions)options
{
    return [[NSData alloc] initWithBase64EncodedString:self options:options];
}

@end
