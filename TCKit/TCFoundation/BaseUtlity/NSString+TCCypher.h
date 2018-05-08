//
//  NSString+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TCCypher)

// for AES

/**
 @brief keySize
 kCCKeySizeAES128          = 16,
 kCCKeySizeAES192          = 24,
 kCCKeySizeAES256          = 32,
 */
- (nullable NSData *)AESEncryptWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize;
- (nullable NSData *)AESDecryptBase64WithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize;
- (nullable NSData *)AESDecryptHexWithKey:(nullable NSData *)key iv:(nullable NSData *)iv keySize:(size_t)keySize;

// for MD5
- (nullable NSString *)MD5_32;
- (nullable NSString *)MD5_16;

/**
 @brief
 case CC_SHA1_DIGEST_LENGTH:
 case CC_SHA256_DIGEST_LENGTH:
 case CC_SHA224_DIGEST_LENGTH:
 case CC_SHA384_DIGEST_LENGTH:
 case CC_SHA512_DIGEST_LENGTH:
 */
- (nullable NSString *)SHAString:(NSUInteger)len;

- (nullable NSString *)Hmac:(CCHmacAlgorithm)alg key:(nullable NSData *)key;

// base64
- (nullable NSString *)base64Encode;
- (nullable NSString *)base64Decode;
- (nullable NSString *)base64DecodeWithOptions:(NSDataBase64DecodingOptions)options;
- (nullable NSData *)base64DecodeData;
@end

NS_ASSUME_NONNULL_END
