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


#include <sys/types.h>


struct rc4_state {
    u_char	perm[256];
    u_char	index1;
    u_char	index2;
};

static __inline void swap_bytes(u_char *a, u_char *b) {
    u_char temp;
    
    temp = *a;
    *a = *b;
    *b = temp;
}

/*
 * Initialize an RC4 state buffer using the supplied key,
 * which can have arbitrary length.  keylen is in bytes.
 */
void rc4_init(
              struct rc4_state* const state,
              const u_char* key,
              NSUInteger keylen
              ) {
    u_char j;
    NSUInteger i;
    
    /* Initialize state with identity permutation */
    for (i = 0; i < 256; i++)
        state->perm[i] = (u_char)i;
    state->index1 = 0;
    state->index2 = 0;
    
    /* Randomize the permutation using key data */
    for (j = i = 0; i < 256; i++) {
        j += state->perm[i] + key[i % keylen];
        swap_bytes(&state->perm[i], &state->perm[j]);
    }
}

/*
 * Encrypt some data using the supplied RC4 state buffer.
 * The input and output buffers may be the same buffer.
 * Since RC4 is a stream cypher, this function is used
 * for both encryption and decryption.
 */
void rc4_crypt(
               struct rc4_state* const state,
               const u_char* inbuf,
               u_char* outbuf,
               NSUInteger buflen
               ) {
    NSUInteger i;
    u_char j;
    
    for (i = 0; i < buflen; i++) {
        
        /* Update modification indicies */
        state->index1++;
        state->index2 += state->perm[state->index1];
        
        /* Modify permutation */
        swap_bytes(&state->perm[state->index1],
                   &state->perm[state->index2]);
        
        /* Encrypt/decrypt next byte */
        j = state->perm[state->index1] + state->perm[state->index2];
        outbuf[i] = inbuf[i] ^ state->perm[j];
    }
}

@implementation NSData (TCCypher)


#pragma mark - Base64

- (instancetype)base64Encode
{
    return  [self base64EncodedDataWithOptions:kNilOptions];
}

- (instancetype)base64Decode
{
    return [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}


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


- (instancetype)AESOperation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv keySize:(size_t)keySize
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


#pragma mark - RC4

+ (NSData *)dataKeyByteCount:(NSInteger)nKeyBytes from7BitString:(NSString *)password
{
    const char *passwordString = password.UTF8String;
    NSMutableData *keyData = NSMutableData.data;
    NSInteger gotBits = 0;
    NSInteger carryBits;
    u_char currentByte = 0;
    u_char nextByte = 0;
    u_char mask = 0;
    u_char newASCIIChar = 0;
    NSInteger gotKeyBytes = 0;
    NSInteger iASCII = 0;
    
    while ((newASCIIChar = (u_char)passwordString[iASCII]) != 0) {
        currentByte = (typeof(currentByte))(currentByte | (newASCIIChar << gotBits)); // "<<" shifts on zeros
        carryBits = 8 - gotBits;
        nextByte = (newASCIIChar >> carryBits); // ">>" shifts in ones but we don't care because they will be masked off later
        gotBits += 7;
        if (gotBits >= 8) {
            [keyData appendBytes:&currentByte
                          length:1];
            gotBits -= 8;
            currentByte = nextByte;
            mask = (typeof(mask))(~(0xff << gotBits));
            currentByte &= mask;
            gotKeyBytes++;
        }
        iASCII++;
    }
    
    if (gotKeyBytes < nKeyBytes) {
        NSLog(
              @"Failed since %ld-bit key requires password of %ld bytes.  Password %@ has only %lu.",
              (long)(nKeyBytes*8),
              (long)ceil((nKeyBytes*8)/7.0),
              password,
              (unsigned long)strlen(passwordString));
        keyData = nil;
    }
    
    return keyData;
}

- (NSData *)cryptRC4WithKeyData:(NSData *)keyData
{
    NSUInteger nKeyBytes = keyData.length;
    u_char key[nKeyBytes];
    [keyData getBytes:key length:nKeyBytes];
    struct rc4_state state;
    rc4_init(&state, key, nKeyBytes);
    NSUInteger nPayloadBytes = self.length;
    unsigned char buf[nPayloadBytes];
    [self getBytes:buf length:nPayloadBytes];
    
    rc4_crypt(&state, buf, buf, nPayloadBytes);
    return [NSData dataWithBytes:buf length:nPayloadBytes];
}

- (instancetype)SHA256Digest
{
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
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
    CFStringInitInlineBuffer((CFStringRef)hexString, &inlineBuffer, CFRangeMake(0, (CFIndex)charLength));
    
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
    
    if (bytePtr <= bytes) {
        free(bytes);
        return nil;
    }
    
    return [self initWithBytesNoCopy:bytes length:(NSUInteger)(bytePtr - bytes) freeWhenDone:YES];
}

- (NSString *)hexStringRepresentation
{
    return [self hexStringRepresentationUppercase:NO seperator:nil width:0];
}

- (NSString *)hexStringRepresentationUppercase:(BOOL)uppercase seperator:(NSString *__nullable)seperator width:(NSUInteger)width
{
    const char *hexTable = uppercase ? "0123456789ABCDEF" : "0123456789abcdef";
    const NSUInteger charLength = self.length * 2;

    
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
    
    NSMutableString *str = [[NSMutableString alloc] initWithBytesNoCopy:hexChars length:charLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
    NSUInteger sepLen = seperator.length;
    BOOL sep = sepLen > 0 && width > 0;
    if (sep) {
        NSUInteger unitCount = (charLength + width - 1) / width;
        
        for (NSUInteger i = 0; i < unitCount; ++i) {
            NSUInteger index = (i + 1) * width + i * sepLen;
            [str insertString:seperator atIndex:index];
        }
 
    }
    
    return str;
}

@end


@implementation NSData (TCHelper)

- (NSRange)rangeOfString:(NSString *)strToFind encoding:(NSStringEncoding)encoding options:(NSDataSearchOptions)mask range:(NSRange * _Nullable)searchRange
{
    NSParameterAssert(strToFind);
    if (nil == strToFind) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    if (0 == encoding) {
        encoding = NSASCIIStringEncoding;
    }
    
    NSData *keyData = [strToFind dataUsingEncoding:encoding];
    if (nil == keyData || self.length < keyData.length) {
        return NSMakeRange(NSNotFound, 0);
    }

    NSRange range;
    if (NULL != searchRange) {
        if (searchRange->location == NSNotFound) {
            searchRange->location = 0;
        }
        
        if (searchRange->length < 1 || searchRange->length > self.length) {
            searchRange->length = self.length;
        }
        
        range = *searchRange;
    } else {
        range.location = 0;
        range.length = self.length;
    }

    return [self rangeOfData:keyData options:mask range:range];
}

@end

