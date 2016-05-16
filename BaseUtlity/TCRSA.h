//
//  TCRSA.h
//  TCKit
//
//  Created by dake on 16/5/16.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

// reference: git@github.com:PanXianyue/XYCryption.git

/**
 @brief	RSA with system keychain
 */
@interface TCRSA : NSObject

+ (instancetype)RSAWithPublicFile:(NSString *)derFile;
+ (instancetype)RSAWithPublicFile:(NSString *)derFile privateFile:(NSString *)p12File passwd:(NSString *)passwd;


#pragma mark - encrypt with public key, decrypt with private key

- (NSData *)encryptData:(NSData *)plainData;
- (NSData *)decryptData:(NSData *)cypherData;

- (NSString *)encryptString:(NSString *)plainStr;
- (NSString *)decryptString:(NSString *)cypherStr;



#pragma mark - sign with private key, verify with public key

/**
 @brief	sign
 
 @param plainData [IN] raw data
 
 @return raw data
 */
- (NSData *)signSHA256Data:(NSData *)plainData;

/**
 @brief	verify
 
 @param plainData [IN] raw data
 @param signData [IN] base64 encoded string data
 
 @return <#return value description#>
 */
- (BOOL)verifySHA256Data:(NSData *)plainData signData:(NSData *)signData;

/**
 @brief	sign
 
 @param plainStr [IN] raw string
 
 @return base64 string
 */
- (NSString *)signSHA256String:(NSString *)plainStr;

/**
 @brief	verify
 
 @param plainStr [IN] raw string
 @param signStr [IN] base64 string
 
 @return <#return value description#>
 */
- (BOOL)verifySHA256String:(NSString *)plainStr sign:(NSString *)signStr;


@end
