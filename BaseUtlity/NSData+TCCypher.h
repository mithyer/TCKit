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
- (instancetype)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (instancetype)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv;

- (instancetype)AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (instancetype)AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv;

@end
