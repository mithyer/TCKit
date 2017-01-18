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

#ifndef TARGET_IS_EXTENSION

- (void)phoneCall:(void(^)(BOOL success))complete;

#endif

- (nullable NSMutableDictionary<NSString *, NSString *> *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;


#pragma mark - pattern

- (NSString *)firstCharacter;

// 去除标点符号, 空白符, 换行符, 空格
- (NSString *)clearSymbolAndWhiteString;

- (BOOL)isPureNumber;
- (BOOL)isValidIDCardNumberOfChina;

@end

NS_ASSUME_NONNULL_END
