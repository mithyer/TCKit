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
- (nullable instancetype)MD5_32;
- (nullable instancetype)MD5_16;

- (nullable instancetype)SHAString:(NSUInteger)len;

- (nullable instancetype)Hmac:(CCHmacAlgorithm)alg key:(nullable NSData *)key;

// base64
- (nullable instancetype)base64Encode;
- (nullable instancetype)base64Decode;
- (nullable NSData *)base64DecodeData;
@end

NS_ASSUME_NONNULL_END
