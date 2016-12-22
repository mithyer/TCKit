//
//  NSData+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSData+TCCypher.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif


@implementation NSData (TCCypher)


#pragma mark - AESCrypt

- (instancetype)AES128EncryptWithKey:(NSString *)key_16_byte iv:(NSString *)iv_16_byte
{
    return [self AESOperation:kCCEncrypt key:key_16_byte iv:iv_16_byte keySize:kCCKeySizeAES128];
}

- (instancetype)AES128DecryptWithKey:(NSString *)key_16_byte iv:(NSString *)iv_16_byte
{
    return [self AESOperation:kCCDecrypt key:key_16_byte iv:iv_16_byte keySize:kCCKeySizeAES128];
}


- (instancetype)AES256EncryptWithKey:(NSString *)key_32_byte iv:(NSString *)iv_16_byte
{
    return [self AESOperation:kCCEncrypt key:key_32_byte iv:iv_16_byte keySize:kCCKeySizeAES256];
}

- (instancetype)AES256DecryptWithKey:(NSString *)key_32_byte iv:(NSString *)iv_16_byte
{
    return [self AESOperation:kCCDecrypt key:key_32_byte iv:iv_16_byte keySize:kCCKeySizeAES256];
}


- (instancetype)AESOperation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv keySize:(int)keySize
{
    char keyPtr[keySize];
    bzero(keyPtr, sizeof(keyPtr));
    if (key.length > 0) {
        memcpy(keyPtr, key.UTF8String, key.length <= keySize ? key.length : keySize);
    }
    
    static size_t const kIvSize = kCCBlockSizeAES128;
    char tmpIvPtr[kIvSize];
    bzero(tmpIvPtr, sizeof(tmpIvPtr));
    
    char *ivPtr = NULL;
    if (iv.length > 0) {
        memcpy(tmpIvPtr, iv.UTF8String, iv.length <= kIvSize ? iv.length : kIvSize);
        ivPtr = tmpIvPtr;
    }
    
    size_t bufferSize = self.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    if (NULL == buffer) {
        return nil;
    }
    bzero(buffer, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          keySize,
                                          ivPtr,
                                          self.bytes,
                                          self.length,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        if (nil != data) {
            return data;
        }
    }
    free(buffer);
    return nil;
}

@end


@implementation NSData (FastHex)

static const uint8_t invalidNibble = 128;

static uint8_t nibbleFromChar(unichar c) {
    if (c >= '0' && c <= '9') {
        return (uint8_t)(c - '0');
    } else if (c >= 'A' && c <= 'F') {
        return (uint8_t)(10 + c - 'A');
    } else if (c >= 'a' && c <= 'f') {
        return (uint8_t)(10 + c - 'a');
    } else {
        return invalidNibble;
    }
}

+ (instancetype)dataWithHexString:(NSString *)hexString
{
    return [[self alloc] initWithHexString:hexString ignoreOtherCharacters:YES];
}

- (nullable instancetype)initWithHexString:(NSString *)hexString ignoreOtherCharacters:(BOOL)ignoreOtherCharacters
{
    if (nil == hexString) {
        return nil;
    }
    
    const NSUInteger charLength = hexString.length;
    const NSUInteger maxByteLength = charLength / 2;
    uint8_t *const bytes = malloc(maxByteLength);
    uint8_t *bytePtr = bytes;
    
    CFStringInlineBuffer inlineBuffer;
    CFStringInitInlineBuffer((CFStringRef)hexString, &inlineBuffer, CFRangeMake(0, charLength));
    
    // Each byte is made up of two hex characters; store the outstanding half-byte until we read the second
    uint8_t hiNibble = invalidNibble;
    for (CFIndex i = 0; i < charLength; ++i) {
        uint8_t nextNibble = nibbleFromChar(CFStringGetCharacterFromInlineBuffer(&inlineBuffer, i));
        
        if (nextNibble == invalidNibble && !ignoreOtherCharacters) {
            free(bytes);
            return nil;
        } else if (hiNibble == invalidNibble) {
            hiNibble = nextNibble;
        } else if (nextNibble != invalidNibble) {
            // Have next full byte
            *bytePtr++ = (uint8_t)((hiNibble << 4) | nextNibble);
            hiNibble = invalidNibble;
        }
    }
    
    if (hiNibble != invalidNibble && !ignoreOtherCharacters) { // trailing hex character
        free(bytes);
        return nil;
    }
    
    return [self initWithBytesNoCopy:bytes length:(bytePtr - bytes) freeWhenDone:YES];
}

- (NSString *)hexStringRepresentation
{
    return [self hexStringRepresentationUppercase:NO];
}

- (NSString *)hexStringRepresentationUppercase:(BOOL)uppercase
{
    const char *hexTable = uppercase ? "0123456789ABCDEF" : "0123456789abcdef";
    
    const NSUInteger byteLength = self.length;
    const NSUInteger charLength = byteLength * 2;
    char *const hexChars = malloc(charLength * sizeof(*hexChars));
    __block char *charPtr = hexChars;
    
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        const uint8_t *bytePtr = bytes;
        for (NSUInteger count = 0; count < byteRange.length; ++count) {
            const uint8_t byte = *bytePtr++;
            *charPtr++ = hexTable[(byte >> 4) & 0xF];
            *charPtr++ = hexTable[byte & 0xF];
        }
    }];
    
    return [[NSString alloc] initWithBytesNoCopy:hexChars length:charLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
