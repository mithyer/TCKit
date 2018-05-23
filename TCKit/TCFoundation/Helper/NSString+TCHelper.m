//
//  NSString+TCHelper.m
//  TCKit
//
//  Created by dake on 16/2/18.
//  Copyright © 2016年 dake. All rights reserved.
//

#import "NSString+TCHelper.h"

#include <netinet/in.h>
#include <arpa/inet.h>

#import <UIKit/UIKit.h>

@interface NSAttributedString (HTML)

+ (instancetype)attributedStringWithHTMLString:(NSString *)htmlString;

@end


@implementation NSString (TCHelper)

- (NSString *)reversedString
{
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:self.length];
    
    [self enumerateSubstringsInRange:NSMakeRange(0,self.length)
                             options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              [reversedString appendString:substring];
                          }];
    return reversedString;
}

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue decodeInf:(BOOL)decodeInf
{
    // Explode based on outter glue
    NSArray<NSString *> *firstExplode = [self componentsSeparatedByString:outterGlue];
    if (firstExplode.count < 2 && [self componentsSeparatedByString:innerGlue].count < 2) {
        NSString *str = self.stringByRemovingPercentEncoding;
        if (nil != str) {
            firstExplode = [str componentsSeparatedByString:outterGlue];
        }
    }
    
    // Explode based on inner glue
    NSMutableDictionary *returnDictionary = NSMutableDictionary.dictionary;
    for (NSUInteger i = 0; i < firstExplode.count; ++i) {
        NSArray<NSString *> *secondExplode = [firstExplode[i] componentsSeparatedByString:innerGlue];
        if (secondExplode.count >= 2) {
            NSString *key = secondExplode[0].stringByRemovingPercentEncoding;
            if (nil == key) {
                continue;
            }
            
            NSString *value = nil;
            if (secondExplode.count == 2) {
                value = secondExplode[1];
            } else {
                value = [firstExplode[i] substringFromIndex:secondExplode[0].length + 1];
            }
            NSString *str = value.stringByRemovingPercentEncoding;
            while (decodeInf && nil != str) {
                @autoreleasepool {
                    NSString *tmp = str.stringByRemovingPercentEncoding;
                    if (nil == tmp || [tmp isEqualToString:str]) {
                        break;
                    }
                    str = tmp;
                }
            }
            if (nil != str) {
                value = str;
            }
            if (nil == value) {
                continue;
            }
            
            returnDictionary[key] = value;
        }
    }
    
    return returnDictionary;
}

- (NSString *)stringByAppendingPathExtensionMust:(NSString *)str
{
    if (nil == str || str.length < 1) {
        return self;
    }
    
    NSString *tmp = [self stringByAppendingPathExtension:str];
    if (nil != tmp) {
        return tmp;
    }
    
    return [self stringByAppendingFormat:@".%@", str];
}

- (nullable NSString *)fixedFileExtension
{
    NSString *decodeUrl = self.stringByRemovingPercentEncoding;
    if (nil == decodeUrl) {
        decodeUrl = self;
    }
    
    NSString *ext = nil;
    if ([decodeUrl hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:decodeUrl];
        if (nil == url) {
            NSString *tmp = [decodeUrl stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
            if (nil != tmp) {
                url = [NSURL URLWithString:tmp];
            }
        }

        if (url.path.length < 1) {
            if (url.query.length < 1) {
                return nil;
            }
        } else {
            ext = url.path;
        }
    } else {
        ext = decodeUrl.lastPathComponent;
    }
    
    // xx.tar.gz
    NSUInteger begin = [ext rangeOfString:@"."].location;
    BOOL findeDot = nil != ext && begin != NSNotFound;
    if (findeDot) {
        ext = [ext substringFromIndex:begin + 1];
    } else {
        begin = [decodeUrl rangeOfString:@"?"].location;
        if (begin == NSNotFound) {
            return nil;
        } else {
            ext = [decodeUrl substringFromIndex:begin + 1];
        }
    }

    if (!findeDot) {
        // /Img/?img=1472541690-6672-2065-1.jpg&img_size=, self.pathExtension 为空
        NSUInteger loc = [ext rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]].location;
        if (loc != NSNotFound) {
            ext = [ext substringFromIndex:loc+1];
        } else {
            return nil;
        }
    }
    
    NSUInteger lastDot = [ext rangeOfString:@"." options:NSBackwardsSearch].location;
    if (lastDot == NSNotFound) {
        lastDot = 0;
    }
    NSUInteger loc = [ext rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"&,;(=?"] options:0 range:NSMakeRange(lastDot, ext.length - lastDot)].location;
    if (loc != NSNotFound) {
        ext = [ext substringToIndex:loc];
    }
    
    if ([ext isEqualToString:@"."]) {
        return nil;
    }
    
    NSArray<NSString *> *exts = [ext componentsSeparatedByString:@"."];
    if (exts.count > 2) {
        exts = [exts subarrayWithRange:NSMakeRange(exts.count - 2, 2)];
        if ([exts.firstObject isEqualToString:@"tar"]/*exts.firstObject.isPureAlphabet*/) {
            ext = [exts componentsJoinedByString:@"."];
        } else {
            ext = exts.lastObject;
        }
    } else if (exts.count == 2) {
        if (exts[0].length < 1) {
            ext = exts[1];
        } else if (exts[1].length < 1) {
            ext = exts[0];
        } else if (![exts.firstObject isEqualToString:@"tar"]/*!exts[0].isPureAlphabet*/) {
            ext = exts[1];
        }
    }
    
    loc = [ext rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"&,;!#"]].location;
    if (loc != NSNotFound) {
        ext = [ext substringToIndex:loc];
    }
    
    if (NSNotFound != [ext rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/%"]].location) {
        return nil;
    }
    
    if (ext.isInteger && ![ext isEqualToString:@"323"]) { // text/h323
        return nil;
    }
    
    return ext.length < 1 ? nil : ext;
}


#pragma mark - pattern

- (NSString *)firstCharacter
{
    return self.length > 0 ? [self substringToIndex:1] : @"";
}

- (NSString *)clearSymbolAndWhiteString
{
    NSMutableCharacterSet *trimSet = [[NSMutableCharacterSet alloc] init];
    [trimSet formUnionWithCharacterSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [trimSet formUnionWithCharacterSet:NSCharacterSet.punctuationCharacterSet];
    [trimSet formUnionWithCharacterSet:NSCharacterSet.controlCharacterSet];
    [trimSet formUnionWithCharacterSet:NSCharacterSet.symbolCharacterSet];
    
    // 去掉前后空格、换行符、标点等
    NSString *trimText = [self stringByTrimmingCharactersInSet:trimSet];
    // 去掉中间的空格
    trimText = [trimText stringByReplacingOccurrencesOfString:@"\x20" withString:@""];
    // 去掉中间的全角空格
    trimText = [trimText stringByReplacingOccurrencesOfString:@"　" withString:@""];
    
    return trimText;
}

- (BOOL)isPureNumber
{
    if (self.length < 1) {
        return NO;
    }
    NSString *str = [self stringByTrimmingCharactersInSet:NSCharacterSet.decimalDigitCharacterSet];
    return str.length < 1 || [str isEqualToString:@"."];
}

- (BOOL)isInteger
{
    if (self.length < 1) {
        return NO;
    }
    NSString *str = [self stringByTrimmingCharactersInSet:NSCharacterSet.decimalDigitCharacterSet];
    return str.length < 1;
}

- (BOOL)isPureAlphabet
{
    if (self.length < 1) {
        return NO;
    }
    NSString *str = [self stringByTrimmingCharactersInSet:NSCharacterSet.letterCharacterSet];
    return str.length < 1;
}

- (BOOL)isValidIDCardNumberOfChina
{
    NSString *code = [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSUInteger length = code.length;
    if (length != 15 && length != 18) {
        return NO;
    }
    
    NSString *pureNumber = nil;
    if (length == 15) {
        pureNumber = code;
    } else {
        pureNumber = [code substringToIndex:length-1];
        NSString *last = [code substringFromIndex:length-1].lowercaseString;
        if (![last isEqualToString:@"x"] && !last.isPureNumber) {
            return NO;
        }
    }
    
    if (!pureNumber.isPureNumber) {
        return NO;
    }
    
    // 地区合法性
    NSArray *const areaCodes = @[@"11", @"12", @"13",@"14", @"15",
                                 @"21", @"22", @"23",
                                 @"31", @"32", @"33", @"34", @"35", @"36", @"37",
                                 @"41", @"42", @"43", @"44", @"45", @"46",
                                 @"50", @"51", @"52", @"53", @"54",
                                 @"61", @"62", @"63", @"64", @"65",
                                 @"71",
                                 @"81", @"82",
                                 @"91"];
    
    NSString *area = [code substringToIndex:2];
    if (![areaCodes containsObject:area]) {
        return NO;
    }
    
    // 出生日期合法性
    static NSString *const kLeapYearExp = @"^((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))$";
    static NSString *const kCommonYearExp = @"^((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))$";
    
    switch (length) {
        case 15: {
            NSInteger year = [code substringWithRange:NSMakeRange(6, 2)].integerValue + 1900;
            if (year <= 1850 || year >= 2200) {
                return NO;
            }
            BOOL isLeapYear = year%400 == 0 || (year%100 != 0 && year%4 == 0);
            NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:isLeapYear ? kLeapYearExp : kCommonYearExp
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:NULL];
            NSUInteger numberofMatch = [exp numberOfMatchesInString:code
                                                            options:NSMatchingReportProgress
                                                              range:NSMakeRange(8, 4)];
            
            return numberofMatch > 0;
        }
            
        case 18: {
            NSInteger year = [code substringWithRange:NSMakeRange(6, 4)].integerValue;
            if (year <= 1850 || year >= 2200) {
                return NO;
            }
            BOOL isLeapYear = year%400 == 0 || (year%100 != 0 && year%4 == 0);
            NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:isLeapYear ? kLeapYearExp : kCommonYearExp
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:NULL];
            NSUInteger numberofMatch = [exp numberOfMatchesInString:code
                                                            options:NSMatchingReportProgress
                                                              range:NSMakeRange(10, 4)];
            
            if (numberofMatch > 0) {
                static NSInteger s_validateCode[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
                static NSInteger s_digits[] = {1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2};
                
                NSInteger sum = 0;
                for (NSUInteger i = 0; i < sizeof(s_validateCode)/sizeof(s_validateCode[0]); ++i) {
                    sum += s_validateCode[i] * [code substringWithRange:NSMakeRange(i, 1)].integerValue;
                }
                
                NSString *last = [code substringFromIndex:length-1];
                if ([last.lowercaseString isEqualToString:@"x"]) {
                    last = @"10";
                }
                
                return s_digits[sum % 11] == last.integerValue;
                
            } else {
                return NO;
            }
        }
            
        default:
            break;
    }
    
    return NO;
}


bool tc_is_ip_addr(char const *host, bool *ipv6)
{
    if (NULL == host) {
        return false;
    }
    struct sockaddr_in sin;
    bzero(&sin, sizeof(sin));
    if (1 == inet_pton(AF_INET, host, &sin)) {
        return true;
    }
    
    struct sockaddr_in6 sin6;
    bzero(&sin6, sizeof(sin6));
    
    bool ret = 1 == inet_pton(AF_INET6, host, &sin6);
    if (NULL != ipv6) {
        *ipv6 = ret;
    }
    return ret;
}

- (BOOL)isIPAddress
{
    return tc_is_ip_addr(self.UTF8String, NULL);
}

#pragma mark - 

+ (NSStringEncoding)encodingForIANACharset:(NSString *)iana
{
    NSStringEncoding encoding = 0;
    if (nil != iana) {
        CFStringEncoding cfcoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)iana);
        if (kCFStringEncodingInvalidId != cfcoding) {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfcoding);
        }
    }
    
    return encoding;
}

+ (nullable NSString *)IANACharsetForEncoding:(NSStringEncoding)encoding
{
    if (0 == encoding) {
        return nil;
    }
    
    CFStringEncoding cfcoding = CFStringConvertNSStringEncodingToEncoding(encoding);
    if (kCFStringEncodingInvalidId == cfcoding) {
        return nil;
    }
    
    return (__bridge_transfer NSString *)CFStringConvertEncodingToIANACharSetName(cfcoding);
}

+ (nullable instancetype)stringWithData:(NSData *)data usedEncoding:(nullable NSStringEncoding *)enc
{
    if (nil == data) {
        return nil;
    }
    
    static NSMutableArray<NSNumber *> *s_tryEncodings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_tryEncodings = [NSMutableArray arrayWithArray:@[
                                                          @(NSUTF8StringEncoding),
                                                          
                                                          @(NSJapaneseEUCStringEncoding),
                                                          @(NSShiftJISStringEncoding),
                                                          ]];
        
        static NSString *const kEds[] = {@"big5hkscs", @"big5", @"gbk", @"gb18030", @"gb2312"};
        for (NSInteger i = 0; i < sizeof(kEds)/sizeof(kEds[0]); ++i) {
            NSStringEncoding ed = [self encodingForIANACharset:kEds[i]];
            if (0 != ed) {
                [s_tryEncodings insertObject:@(ed) atIndex:1];
            }
        }
    });
    
    NSString *text = nil;
    for (NSNumber *ed in s_tryEncodings) {
        text = [[self alloc] initWithData:data encoding:ed.unsignedIntegerValue];// [NSString stringWithContentsOfURL:self.URL usedEncoding:NULL error:NULL];
        if (nil != text) {
            if (NULL != enc) {
                *enc = ed.unsignedIntegerValue;
            }
            break;
        }
    }
    
    return text;
}

- (NSString *)stringByUnescapingHTML
{
    if (self.length < 1) {
        return self;
    }
    
    return [NSAttributedString attributedStringWithHTMLString:self].string;
}

@end


@implementation NSAttributedString (HTML)

+ (instancetype)attributedStringWithHTMLString:(NSString *)htmlString
{
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                              NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:NULL];
}

@end
