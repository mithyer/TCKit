//
//  NSString+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TCCypher)

// for AES
- (nullable instancetype)AES128EncryptBase64WithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES128DecryptBase64WithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;

- (nullable instancetype)AES256EncryptBase64WithKey:(NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES256DecryptBase64WithKey:(NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;

- (nullable instancetype)AES128EncryptHexWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES128DecryptHexWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;

- (nullable instancetype)AES256EncryptHexWithKey:(NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES256DecryptHexWithKey:(NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;

// for MD5
- (nullable instancetype)MD5_32;
- (nullable instancetype)MD5_16;

- (nullable instancetype)SHA_1;

// base64
- (nullable instancetype)base64Encode;
- (nullable instancetype)base64Decode;

@end

NS_ASSUME_NONNULL_END
