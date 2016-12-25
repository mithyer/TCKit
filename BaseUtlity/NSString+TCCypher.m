//
//  NSString+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSString+TCCypher.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+TCCypher.h"


#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSString (TCCypher)


#pragma mark - AES

- (nullable instancetype)AES128EncryptBase64WithKey:(NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte
{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] AES128EncryptWithKey:key_16_byte iv:iv_16_byte];
    return [data base64EncodedStringWithOptions:kNilOptions];
}

- (nullable instancetype)AES128DecryptBase64WithKey:(NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte
{
    NSData *data = [[[NSData alloc] initWithBase64EncodedString:self.base64Decode options:NSDataBase64DecodingIgnoreUnknownCharacters] AES128DecryptWithKey:key_16_byte iv:iv_16_byte];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (instancetype)AES256EncryptBase64WithKey:(NSString *)key iv:(NSString *)iv
{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key iv:iv];
    return [data base64EncodedStringWithOptions:kNilOptions];
}

- (instancetype)AES256DecryptBase64WithKey:(NSString *)key iv:(NSString *)iv
{
    NSData *data = [[[NSData alloc] initWithBase64EncodedString:self.base64Decode options:NSDataBase64DecodingIgnoreUnknownCharacters] AES256DecryptWithKey:key iv:iv];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (nullable instancetype)AES128EncryptHexWithKey:(NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte
{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] AES128EncryptWithKey:key_16_byte iv:iv_16_byte];
    return data.hexStringRepresentation;
}

- (nullable instancetype)AES128DecryptHexWithKey:(NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte
{
    NSData *data = [[NSData dataWithHexString:self] AES128DecryptWithKey:key_16_byte iv:iv_16_byte];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (instancetype)AES256EncryptHexWithKey:(NSString *)key iv:(NSString *)iv
{
    NSData *data = [[self dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key iv:iv];
    return data.hexStringRepresentation;
}

- (instancetype)AES256DecryptHexWithKey:(NSString *)key iv:(NSString *)iv
{
    NSData *data = [[NSData dataWithHexString:self] AES256DecryptWithKey:key iv:iv];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}


#pragma mark - MD5

- (instancetype)MD5_32
{
    if (self.length < 1) {
        return nil;
    }
    
    const char *value = self.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; ++count) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (instancetype)MD5_16
{
    NSString *str = self.MD5_32;
    return nil != str ? [str substringWithRange:NSMakeRange(8, 16)] : str;
}

- (instancetype)SHA_1
{
    if (self.length < 1) {
        return nil;
    }
    
    const char *value = self.UTF8String;
    
    size_t len = strlen(value);
    Byte byteArray[len];
    for (NSInteger i = 0; i < len; ++i) {
        unsigned eachChar = *(value + i);
        byteArray[i] = eachChar & 0xFF;
    }
    
    unsigned char outputBuffer[CC_SHA1_DIGEST_LENGTH];
    bzero(outputBuffer, sizeof(outputBuffer));
    CC_SHA1(byteArray, (CC_LONG)len, outputBuffer);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_SHA1_DIGEST_LENGTH; ++count) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (instancetype)base64Encode
{
    return  [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:kNilOptions];
}

- (instancetype)base64Decode
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return nil != data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}


@end
