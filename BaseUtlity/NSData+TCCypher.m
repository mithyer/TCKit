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
    char keyPtr[keySize + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char *ivPtr = NULL;
    if (iv.length > 0) {
        char tmpIvPtr[kCCBlockSizeAES128 + 1];
        bzero(tmpIvPtr, sizeof(tmpIvPtr));
        [iv getCString:tmpIvPtr maxLength:sizeof(tmpIvPtr) encoding:NSUTF8StringEncoding];
        ivPtr = tmpIvPtr;
    }
    
    NSUInteger dataLength = self.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    if (NULL == buffer) {
        return nil;
    }
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          self.bytes,
                                          dataLength,
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

/*
#pragma mark - RSA

// 加解密之 pem 公钥: https://blog.cnbluebox.com/blog/2014/03/19/rsajia-mi/
// http://www.jianshu.com/p/a1bad1e2be55

NSData* PKCSSignBytesSHA256withRSA(NSData* plainData, SecKeyRef privateKey)
{
    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);
    
    size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        return nil;
    }
    
    SecKeyRawSign(privateKey,
                  kSecPaddingPKCS1SHA256,
                  hashBytes,
                  hashBytesSize,
                  signedHashBytes,
                  &signedHashBytesSize);
    
    NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                        length:(NSUInteger)signedHashBytesSize];
    
    if (hashBytes)
        free(hashBytes);
    if (signedHashBytes)
        free(signedHashBytes);
    
    return signedHash;
}

BOOL PKCSVerifyBytesSHA256withRSA(NSData* plainData, NSData* signature, SecKeyRef publicKey)
{
    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    const void* signedHashBytes = [signature bytes];
    
    size_t hashBytesSize = CC_SHA256_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        return nil;
    }
    
    OSStatus status = SecKeyRawVerify(publicKey,
                                      kSecPaddingPKCS1SHA256,
                                      hashBytes,
                                      hashBytesSize,
                                      signedHashBytes,
                                      signedHashBytesSize);
    
    return status == errSecSuccess;
}

 */

@end
