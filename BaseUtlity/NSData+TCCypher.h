//
//  NSData+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (TCCypher)

// for AES
- (nullable instancetype)AES128EncryptWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES128DecryptWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;

- (nullable instancetype)AES256EncryptWithKey:(nullable NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES256DecryptWithKey:(nullable NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;

@end

NS_ASSUME_NONNULL_END
