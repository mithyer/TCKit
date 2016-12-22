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

NS_ASSUME_NONNULL_END
