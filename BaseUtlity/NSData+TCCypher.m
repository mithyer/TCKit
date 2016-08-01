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

- (instancetype)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESOperation:kCCEncrypt key:key iv:iv keySize:kCCKeySizeAES128];
}

- (instancetype)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESOperation:kCCDecrypt key:key iv:iv keySize:kCCKeySizeAES128];
}


- (instancetype)AES256EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESOperation:kCCEncrypt key:key iv:iv keySize:kCCKeySizeAES256];
}

- (instancetype)AES256DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESOperation:kCCDecrypt key:key iv:iv keySize:kCCKeySizeAES256];
}



- (instancetype)AESOperation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv keySize:(int)keySize
{
    char keyPtr[keySize];
    bzero(keyPtr, sizeof(keyPtr));
    if (key.length > 0) {
        memcpy(keyPtr, key.UTF8String, key.length <= keySize ? key.length : keySize);
    }
    
    char tmpIvPtr[kCCBlockSizeAES128];
    bzero(tmpIvPtr, sizeof(tmpIvPtr));
    
    char *ivPtr = NULL;
    if (iv.length > 0) {
        memcpy(tmpIvPtr, iv.UTF8String, iv.length <= kCCBlockSizeAES128 ? iv.length : kCCBlockSizeAES128);
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
