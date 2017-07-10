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


// Base64
- (instancetype)base64Encode;
- (instancetype)base64Decode;


// AES
- (nullable instancetype)AES128EncryptWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES128DecryptWithKey:(nullable NSString *)key_16_byte iv:(nullable NSString *)iv_16_byte;

- (nullable instancetype)AES256EncryptWithKey:(nullable NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;
- (nullable instancetype)AES256DecryptWithKey:(nullable NSString *)key_32_byte iv:(nullable NSString *)iv_16_byte;

// RC4
// Utility method for generating keys from string passwords
+ (nullable NSData *)dataKeyByteCount:(NSInteger)nKeyBytes
                       from7BitString:(NSString *)password;
// nKeyBytes may be of
// any length, although if you believe the fiction that
// making it incredibly easy for the U.S. government to eavesdrop
// is somehow protecting the world from terrorists, I believe USA
// citizens are supposed to limit nKeyBytes to maximum 7 (56 bits)
// or something stupid like that, in any exported product.

// Password will be converted to a null-terminated UTF8 string and
// the most significant bit of each byte will be ignored.
// Therefore, if password is all 127-bit low ASCII, the number of
// characters required is ceil(nKeyBytes/7).

// Because the null-termination is detected, the NUL character
// (Unicode U+0000) is not allowed in the password.  (According to
// Wikipedia, NUL is the only UTF8 sequence which includes the
// byte 0x00.)

// To determine the number of bytes in a password with non-ASCII
// characters, you may use -[NSString lengthOfBytesUsingEncoding:]
// with argument NSUTF8StringEncoding (requires Mac OS 10.4 or later).

// Since RC4 is a symmetric stream encryption, the same method
// is used for encrypting and decrypting.
- (NSData *)cryptRC4WithKeyData:(NSData *)keyData;
// Data returned will be same byte count (-length) as receiver.

@end


@interface NSData (FastHex)

/** Returns an NSData instance constructed from the hex characters of the passed string.
 * A convenience method for \p -initWithHexString:ignoreOtherCharacters: with the value
 * YES for \p ignoreOtherCharacters . */
+ (instancetype)dataWithHexString:(NSString *)hexString;

/** Initializes the NSData instance with data from the hex characters of the passed string.
 *
 * \param hexString A string containing ASCII hexadecimal characters (uppercase and lowercase accepted).
 * \param ignoreOtherCharacters If YES, skips non-hexadecimal characters, and trailing characters.
 *  If NO, non-hexadecimal or trailing characters will abort parsing and this method will return nil.
 *
 * \return the initialized data instance, or nil if \p ignoreOtherCharacters is NO and \p hexString
 * contains a non-hex or trailing character. If \p hexString is the empty string, returns an empty
 * (non-nil) NSData instance. */
- (nullable instancetype)initWithHexString:(NSString *)hexString ignoreOtherCharacters:(BOOL)ignoreOtherCharacters;

/** Returns a string of the receiver's data bytes as uppercase hexadecimal characters. */
- (NSString *)hexStringRepresentation;

/** Returns a string of the receiver's data bytes as uppercase or lowercase hexadecimal characters.
 *
 * \param uppercase YES to use uppercase letters A-F; NO for lowercase a-f
 */
- (NSString *)hexStringRepresentationUppercase:(BOOL)uppercase;

@end


@interface NSData (TCHelper)

- (NSRange)rangeOfString:(NSString *)strToFind encoding:(NSStringEncoding)encoding options:(NSDataSearchOptions)mask range:(NSRange * _Nullable)searchRange;

@end

NS_ASSUME_NONNULL_END
