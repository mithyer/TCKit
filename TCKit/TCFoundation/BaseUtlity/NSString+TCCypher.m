//
//  NSString+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSString+TCCypher.h"
#import "NSData+TCCypher.h"


#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSString (TCCypher)


#pragma mark - AES

- (nullable NSData *)AESEncryptWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] AESOperation:kCCEncrypt key:key iv:iv keySize:keySize];
}

- (nullable NSData *)AESDecryptBase64WithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters] AESOperation:kCCDecrypt key:key iv:iv keySize:keySize];
}

- (nullable NSData *)AESDecryptHexWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize
{
    return [[NSData dataWithHexString:self] AESOperation:kCCDecrypt key:key iv:iv keySize:keySize];
}


#pragma mark - MD5

- (instancetype)MD5_32
{
    if (self.length < 1) {
        return nil;
    }
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    CC_MD5(self.UTF8String, (CC_LONG)self.length, outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [outputString appendFormat:@"%02x", outputBuffer[i]];
    }
    
    return outputString;
}

- (instancetype)MD5_16
{
    NSString *str = self.MD5_32;
    return nil != str ? [str substringWithRange:NSMakeRange(8, 16)] : str;
}

- (instancetype)SHAString:(NSUInteger)len
{
    unsigned char result[len];
    
    switch (len) {
        case CC_SHA1_DIGEST_LENGTH:
            CC_SHA1(self.UTF8String, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA256_DIGEST_LENGTH:
            CC_SHA256(self.UTF8String, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA224_DIGEST_LENGTH:
            CC_SHA224(self.UTF8String, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA384_DIGEST_LENGTH:
            CC_SHA384(self.UTF8String, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA512_DIGEST_LENGTH:
            CC_SHA512(self.UTF8String, (CC_LONG)self.length, result);
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

- (nullable instancetype)Hmac:(CCHmacAlgorithm)alg key:(nullable NSData *)key
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
    CCHmac(alg, key.bytes, key.length, self.UTF8String, self.length, buf);
    NSMutableString *outputString = [NSMutableString stringWithCapacity:digestLen * 2];
    for (NSUInteger i = 0; i < digestLen; ++i) {
        [outputString appendFormat:@"%02x", buf[i]];
    }
    return outputString;
}

- (instancetype)base64Encode
{
    return  [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

- (instancetype)base64Decode
{
    NSData *data = self.base64DecodeData;
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (nullable NSData *)base64DecodeData
{
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@end
