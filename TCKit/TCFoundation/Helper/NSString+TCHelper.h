//
//  NSString+TCHelper.h
//  TCKit
//
//  Created by dake on 16/2/18.
//  Copyright © 2016年 dake. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TCHelper)

- (nullable NSMutableDictionary<NSString *, NSString *> *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;
- (nullable NSString *)fixedFileExtension;

#pragma mark - pattern

- (NSString *)firstCharacter;

// 去除标点符号, 空白符, 换行符, 空格
- (NSString *)clearSymbolAndWhiteString;

- (BOOL)isInteger;
- (BOOL)isPureNumber;
- (BOOL)isPureAlphabet;
- (BOOL)isValidIDCardNumberOfChina;

/**
 @brief	convert IANA charset name encoding
 
 @param iana [IN] IANA charset name
 
 @return 0, if failed
 */
+ (NSStringEncoding)encodingForIANACharset:(NSString *)iana;
+ (nullable NSString *)IANACharsetForEncoding:(NSStringEncoding)encoding;
+ (nullable instancetype)stringWithData:(NSData *)data usedEncoding:(nullable NSStringEncoding *)enc;

@end

NS_ASSUME_NONNULL_END
