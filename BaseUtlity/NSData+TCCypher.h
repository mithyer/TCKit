//
//  NSData+TCCypher.h
//  TCKit
//
//  Created by dake on 15/3/11.
//  Copyright (c) 2015年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TCCypher)

// for AES
- (instancetype)AES128EncryptWithKey:(NSString *)key_16 iv:(NSString *)iv_16;
- (instancetype)AES128DecryptWithKey:(NSString *)key_16 iv:(NSString *)iv_16;

- (instancetype)AES256EncryptWithKey:(NSString *)key_32 iv:(NSString *)iv_16;
- (instancetype)AES256DecryptWithKey:(NSString *)key_32 iv:(NSString *)iv_16;

@end
