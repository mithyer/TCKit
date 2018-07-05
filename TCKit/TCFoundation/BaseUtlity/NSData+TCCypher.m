//
//  NSData+TCCypher.m
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import "NSData+TCCypher.h"

#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif


static void fixKeyLengths(CCAlgorithm algorithm, NSMutableData *keyData, NSMutableData *ivData)
{
    NSUInteger keyLength = keyData.length;
    NSUInteger ivLen = 0;
    switch (algorithm) {
        case kCCAlgorithmAES: {
            if (keyLength <= kCCKeySizeAES128) {
                keyData.length = kCCKeySizeAES128;
            } else if (keyLength <= kCCKeySizeAES192) {
                keyData.length = kCCKeySizeAES192;
            } else if (keyLength <= kCCKeySizeAES256) {
                keyData.length = kCCKeySizeAES256;
            }
            
            ivLen = kCCBlockSizeAES128;
            break;
        }
            
        case kCCAlgorithmDES: {
            keyData.length = kCCKeySizeDES;
            ivLen = kCCBlockSizeDES;
            break;
        }
            
        case kCCAlgorithm3DES: {
            keyData.length = kCCKeySize3DES;
            ivLen = kCCBlockSize3DES;
            break;
        }
            
        case kCCAlgorithmCAST: {
            if (keyLength <= kCCKeySizeMinCAST) {
                keyData.length = kCCKeySizeMinCAST;
            } else if (keyLength > kCCKeySizeMaxCAST) {
                keyData.length = kCCKeySizeMaxCAST;
            }
            ivLen = kCCBlockSizeCAST;
            break;
        }
            
        case kCCAlgorithmRC4: {
            if (keyLength <= kCCKeySizeMinRC4) {
                keyData.length = kCCKeySizeMinRC4;
            } else if (keyLength > kCCKeySizeMaxRC4) {
                keyData.length = kCCKeySizeMaxRC4;
            }
            break;
        }
            
        case kCCAlgorithmRC2: {
            if (keyLength <= kCCKeySizeMinRC2) {
                keyData.length = kCCKeySizeMinRC2;
            } else if (keyLength > kCCKeySizeMaxRC2) {
                keyData.length = kCCKeySizeMaxRC2;
            }
            ivLen = kCCBlockSizeRC2;
            break;
        }
            
        case kCCAlgorithmBlowfish: {
            if (keyLength <= kCCKeySizeMinBlowfish) {
                keyData.length = kCCKeySizeMinBlowfish;
            } else if (keyLength > kCCKeySizeMaxBlowfish) {
                keyData.length = kCCKeySizeMaxBlowfish;
            }
            ivLen = kCCBlockSizeBlowfish;
            break;
        }
            
        default:
            break;
    }
    
    if (nil != ivData && ivLen > 0) {
        ivData.length = ivLen;
    }
}



NSString *const TCCommonCryptoErrorDomain = @"TCCommonCryptoErrorDomain";

@implementation NSError (CommonCryptoErrorDomain)

+ (NSError *)errorWithCCCryptorStatus:(CCCryptorStatus)status
{
    NSString *description = nil, *reason = nil;
    
    switch (status) {
        case kCCSuccess:
            return nil;
            
        case kCCParamError:
            description = NSLocalizedString(@"Parameter Error", @"Error description");
            reason = NSLocalizedString(@"Illegal parameter supplied to encryption/decryption algorithm", @"Error reason");
            break;
            
        case kCCBufferTooSmall:
            description = NSLocalizedString(@"Buffer Too Small", @"Error description");
            reason = NSLocalizedString(@"Insufficient buffer provided for specified operation", @"Error reason");
            break;
            
        case kCCMemoryFailure:
            description = NSLocalizedString(@"Memory Failure", @"Error description");
            reason = NSLocalizedString(@"Failed to allocate memory", @"Error reason");
            break;
            
        case kCCAlignmentError:
            description = NSLocalizedString(@"Alignment Error", @"Error description");
            reason = NSLocalizedString(@"Input size to encryption algorithm was not aligned correctly", @"Error reason");
            break;
            
        case kCCDecodeError:
            description = NSLocalizedString(@"Decode Error", @"Error description");
            reason = NSLocalizedString(@"Input data did not decode or decrypt correctly", @"Error reason");
            break;
            
        case kCCUnimplemented:
            description = NSLocalizedString(@"Unimplemented Function", @"Error description");
            reason = NSLocalizedString(@"Function not implemented for the current algorithm", @"Error reason");
            break;
            
        default:
            description = NSLocalizedString(@"Unknown Error", @"Error description");
            reason = NSLocalizedString(@"Unknown Error", @"Error description");
            break;
    }
    
    NSMutableDictionary *userInfo = NSMutableDictionary.dictionary;
    userInfo[NSLocalizedDescriptionKey] = description;
    if (reason != nil) {
         userInfo[NSLocalizedFailureReasonErrorKey] = reason;
    }
    
    return [NSError errorWithDomain:TCCommonCryptoErrorDomain code:status userInfo:userInfo];
}

@end

@implementation NSData (TCCypher)


#pragma mark - Base64

- (NSData *)base64Encode
{
    return [self base64EncodedDataWithOptions:kNilOptions];
}

- (NSData *)base64DecodeWithOptions:(NSDataBase64DecodingOptions)ops
{
    return [[NSData alloc] initWithBase64EncodedData:self options:ops];
}

- (NSData *)base64Decode
{
    return [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (NSString *)base64EncodeString
{
    return [self base64EncodedStringWithOptions:kNilOptions];
}


#pragma mark - AESCrypt

//- (instancetype)AESOperation:(CCOperation)operation option:(CCOptions)option key:(NSData *)key iv:(NSData *)iv keySize:(size_t)keySize
//{
//    if (operation == kCCDecrypt) {
//        if (self.length % kCCBlockSizeAES128 != 0) {
//            return nil;
//        }
//    }
//
//    char keyPtr[keySize];
//    bzero(keyPtr, sizeof(keyPtr));
//    if (key.length > 0) {
//        memcpy(keyPtr, key.bytes, key.length <= keySize ? key.length : keySize);
//    }
//
//    static size_t const kIvSize = kCCBlockSizeAES128;
//    char tmpIvPtr[kIvSize];
//    bzero(tmpIvPtr, sizeof(tmpIvPtr));
//
//    char *ivPtr = NULL;
//    if (iv.length > 0) {
//        memcpy(tmpIvPtr, iv.bytes, iv.length <= kIvSize ? iv.length : kIvSize);
//        ivPtr = tmpIvPtr;
//    }
//
//    size_t bufferSize = 0;
//    if (operation == kCCEncrypt) {
//        bufferSize = (self.length/kCCBlockSizeAES128 + 1) * kCCBlockSizeAES128;
//    } else {
//        bufferSize = self.length;
//    }
//
//    void *buffer = malloc(bufferSize);
//    if (NULL == buffer) {
//        return nil;
//    }
//    bzero(buffer, bufferSize);
//
//    size_t numBytesCrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(operation,
//                                          kCCAlgorithmAES,
//                                          kCCOptionPKCS7Padding,
//                                          keyPtr,
//                                          keySize,
//                                          ivPtr,
//                                          self.bytes,
//                                          self.length,
//                                          buffer,
//                                          bufferSize,
//                                          &numBytesCrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
//        if (nil != data) {
//            return data;
//        }
//    }
//    free(buffer);
//    return nil;
//}


- (nullable NSData *)dataUsingAlgorithm:(CCAlgorithm)algorithm
                              operation:(CCOperation)operation
                                    key:(NSData *)key
                                     iv:(NSData *)iv
                                options:(CCOptions)options
                                  error:(CCCryptorStatus *)error
{
    NSMutableData *keyData = key.mutableCopy ?: NSMutableData.data;
    NSMutableData *ivData = iv.mutableCopy;
    fixKeyLengths(algorithm, keyData, ivData);
    
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = CCCryptorCreate(operation,
                                             algorithm,
                                             options,
                                             keyData.bytes,
                                             keyData.length,
                                             ivData.bytes,
                                             &cryptor);
    
    if (status != kCCSuccess) {
        if (error != NULL) {
            *error = status;
        }
        if (NULL != cryptor) {
            CCCryptorRelease(cryptor);
        }
        return nil;
    }
    
    NSData *result = [self _runCryptor:cryptor result:&status];
    if (result == nil && error != NULL) {
        *error = status;
    }
    CCCryptorRelease(cryptor);
    return result;
}

- (NSData *)_runCryptor:(CCCryptorRef)cryptor result:(CCCryptorStatus *)status
{
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)self.length, true);
    if (bufsize < 1) {
        *status = kCCAlignmentError;
        return nil;
    }
    void *buf = malloc(bufsize);
    if (NULL == buf) {
        return nil;
    }
    
    size_t bufused = 0;
    size_t bytesTotal = 0;
    *status = CCCryptorUpdate(cryptor, self.bytes, (size_t)self.length, buf, bufsize, &bufused);
    if (*status != kCCSuccess) {
        free(buf);
        return nil;
    }
    
    bytesTotal += bufused;
    
    // From Brent Royal-Gordon (Twitter: architechies):
    //  Need to update buf ptr past used bytes when calling CCCryptorFinal()
    *status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);
    if (*status != kCCSuccess) {
        free(buf);
        return nil;
    }
    
    bytesTotal += bufused;
    return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}

- (nullable NSData *)cryptoOperation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm option:(CCOptions)option key:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize error:(NSError **)error
{
    NSMutableData *keyData = key.mutableCopy ?: NSMutableData.data;
    if (keySize > 0) {
        keyData.length = keySize;
    }
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [self dataUsingAlgorithm:algorithm
                                    operation:operation
                                          key:keyData
                                           iv:iv
                                      options:option
                                        error:&status];
    
    if (result != nil) {
        return result;
    }
    
    if (error != NULL) {
        *error = [NSError errorWithCCCryptorStatus:status];
    }
    return nil;
}

- (nullable NSData *)RC4:(CCOperation)operation key:(nullable NSData *)key
{
    return [self cryptoOperation:operation algorithm:kCCAlgorithmRC4 option:0 key:key iv:nil keySize:0 error:NULL];
}

// SHA
- (NSData *)SHADigest:(NSUInteger)len
{
    unsigned char result[len];
    
    switch (len) {
        case CC_SHA1_DIGEST_LENGTH:
             CC_SHA1(self.bytes, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA256_DIGEST_LENGTH:
            CC_SHA256(self.bytes, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA224_DIGEST_LENGTH:
            CC_SHA224(self.bytes, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA384_DIGEST_LENGTH:
            CC_SHA384(self.bytes, (CC_LONG)self.length, result);
            break;
            
        case CC_SHA512_DIGEST_LENGTH:
            CC_SHA512(self.bytes, (CC_LONG)self.length, result);
            break;
            
        default:
            return nil;
    }
    
    return [NSData dataWithBytes:result length:len];
}

- (nullable NSString *)SHAString:(NSUInteger)len
{
    NSData *data = [self SHADigest:len];
    if (nil == data) {
        return nil;
    }
    
    const unsigned char *result = data.bytes;
    NSUInteger dataLen = data.length;
    NSMutableString *outputString = [NSMutableString stringWithCapacity:dataLen * 2];
    for (NSUInteger i = 0; i < dataLen; ++i) {
        [outputString appendFormat:@"%02x", result[i]];
    }
    return outputString;
}

- (nullable NSData *)Hmac:(CCHmacAlgorithm)alg key:(nullable NSData *)key
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
    bzero(buf, digestLen);
    CCHmac(alg, key.bytes, key.length, self.bytes, self.length, buf);
    return [NSData dataWithBytes:buf length:digestLen];
}

- (nullable NSString *)HmacString:(CCHmacAlgorithm)alg key:(nullable NSData *)key
{
    NSData *data = [self Hmac:alg key:key];
    if (nil == data) {
        return nil;
    }
    
    const unsigned char *result = data.bytes;
    NSUInteger dataLen = data.length;
    NSMutableString *outputString = [NSMutableString stringWithCapacity:dataLen * 2];
    for (NSUInteger i = 0; i < dataLen; ++i) {
        [outputString appendFormat:@"%02x", result[i]];
    }
    return outputString;
}

- (NSData *)MD5_32
{
    unsigned char buf[CC_MD5_DIGEST_LENGTH];
    bzero(buf, sizeof(buf));
    CC_MD5(self.bytes, (CC_LONG)self.length, buf);
    return [NSData dataWithBytes:buf length:CC_MD5_DIGEST_LENGTH];
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

- (nullable NSData *)extractFromHexData:(BOOL)ignoreOtherCharacters
{
    const NSUInteger charLength = self.length;
    const NSUInteger maxByteLength = charLength / 2;
    uint8_t *const bytes = malloc(maxByteLength);
    if (NULL == bytes) {
        return nil;
    }
    uint8_t *bytePtr = bytes;
    
    const uint8_t *rawBytes = self.bytes;
    
    uint8_t hiNibble = invalidNibble;
    for (CFIndex i = 0; i < charLength; ++i) {
        uint8_t nextNibble = nibbleFromChar(rawBytes[i]);
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
  
    return [NSData dataWithBytesNoCopy:bytes length:(NSUInteger)(bytePtr - bytes) freeWhenDone:YES];
}

- (nullable instancetype)initWithHexString:(NSString *)hexString ignoreOtherCharacters:(BOOL)ignoreOtherCharacters
{
    if (nil == hexString) {
        return nil;
    }
    
    const NSUInteger charLength = hexString.length;
    const NSUInteger maxByteLength = charLength / 2;
    uint8_t *const bytes = malloc(maxByteLength);
    if (NULL == bytes) {
        return nil;
    }
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

