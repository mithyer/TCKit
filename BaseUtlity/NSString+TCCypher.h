//
//  NSString+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCCypher)

// for AES
- (instancetype)AES256EncryptWithKey:(NSString *)key_32 iv:(NSString *)iv_16;
- (instancetype)AES256DecryptWithKey:(NSString *)key_32 iv:(NSString *)iv_16;

// for MD5
- (instancetype)MD5_32;
- (instancetype)MD5_16;

- (instancetype)SHA_1;

@end
